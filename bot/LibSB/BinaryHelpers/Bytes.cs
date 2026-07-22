using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;
namespace LibSwitchboard.BinaryHelpers;

public class ByteLayer
{
    private byte[] _byteBuffer;
    private int _position;

    public ByteLayer()
    {
        _byteBuffer = new byte[0];
        _position = 0;
    }

    public int Length => _byteBuffer.Length;

    public int CurrentPosition => _position;

    public byte[] Bytes => _byteBuffer.Take(_position).ToArray();

    private void EnsureCapacity(int additionalBytes)
    {
        int requiredCapacity = _position + additionalBytes;
        if (requiredCapacity > _byteBuffer.Length)
        {
            Array.Resize(ref _byteBuffer, requiredCapacity);
        }
    }

    public void WriteInt(int value)
    {
        EnsureCapacity(4);
        Array.Copy(BitConverter.GetBytes(value), 0, _byteBuffer, _position, 4);
        if (BitConverter.IsLittleEndian)
            Array.Reverse(_byteBuffer, _position, 4);
        _position += 4;
    }

    public int ReadInt()
    {
        if (_position + 4 > _byteBuffer.Length) throw new InvalidOperationException("Buffer overflow.");
        var value = _byteBuffer.Skip(_position).Take(4).ToArray();
        if (BitConverter.IsLittleEndian) Array.Reverse(value);
        _position += 4;
        return BitConverter.ToInt32(value, 0);
    }

    public void WriteDouble(double value)
    {
        EnsureCapacity(8);
        var bytes = BitConverter.GetBytes(value);
        if (BitConverter.IsLittleEndian)
            Array.Reverse(bytes);
        Array.Copy(bytes, 0, _byteBuffer, _position, 8);
        _position += 8;
    }

    public double ReadDouble()
    {
        if (_position + 8 > _byteBuffer.Length) throw new InvalidOperationException("Buffer overflow.");
        var value = _byteBuffer.Skip(_position).Take(8).ToArray();
        if (BitConverter.IsLittleEndian) Array.Reverse(value);
        _position += 8;
        return BitConverter.ToDouble(value, 0);
    }

    public void WriteFloat(float value)
    {
        EnsureCapacity(4);
        var bytes = BitConverter.GetBytes(value);
        if (BitConverter.IsLittleEndian)
            Array.Reverse(bytes);

        Array.Copy(bytes, 0, _byteBuffer, _position, 4);
        _position += 4;
    }

    public float ReadFloat()
    {
        if (_position + 4 > _byteBuffer.Length) throw new InvalidOperationException("Buffer overflow.");
        var value = _byteBuffer.Skip(_position).Take(4).ToArray();
        if (BitConverter.IsLittleEndian) Array.Reverse(value);
        _position += 4;
        return BitConverter.ToSingle(value, 0);
    }

    public void WriteString(string value)
    {
        var encoded = Encoding.UTF8.GetBytes(value);
        WriteShort((short)encoded.Length);
        EnsureCapacity(encoded.Length);
        Array.Copy(encoded, 0, _byteBuffer, _position, encoded.Length);
        _position += encoded.Length;
    }

    public string ReadString()
    {
        int length = ReadShort();
        if (_position + length > _byteBuffer.Length) throw new InvalidOperationException("Buffer overflow.");
        var value = Encoding.UTF8.GetString(_byteBuffer, _position, length);
        _position += length;
        return value;
    }

    public void WriteShort(short value)
    {
        EnsureCapacity(2);
        var bytes = BitConverter.GetBytes((short)value);
        if (BitConverter.IsLittleEndian)
            Array.Reverse(bytes);
        Array.Copy(bytes, 0, _byteBuffer, _position, 2);
        _position += 2;
    }

    public short ReadShort()
    {
        if (_position + 2 > _byteBuffer.Length) throw new InvalidOperationException("Buffer overflow.");
        var value = _byteBuffer.Skip(_position).Take(2).ToArray();
        if (BitConverter.IsLittleEndian) Array.Reverse(value);
        _position += 2;
        return BitConverter.ToInt16(value, 0);
    }

    public void WriteByte(byte value)
    {
        EnsureCapacity(1);
        _byteBuffer[_position] = value;
        _position++;
    }

    public void WriteBytes(List<byte> bytes)
    {
        EnsureCapacity(bytes.Count);
        Array.Copy(bytes.ToArray(), 0, _byteBuffer, _position, bytes.Count);
        _position += bytes.Count;
    }

    public byte ReadByte()
    {
        if (_position >= _byteBuffer.Length) throw new InvalidOperationException("Buffer overflow.");
        return _byteBuffer[_position++];
    }

    public void ResetPosition() => _position = 0;

    public void RestorePosition(int position)
    {
        if (position < 0 || position > _byteBuffer.Length)
            throw new ArgumentOutOfRangeException(nameof(position));
        _position = position;
    }

    public void Clear()
    {
        _position = 0;
        _byteBuffer = new byte[0];
    }

    public void WriteToFile(string filePath)
    {
        File.WriteAllBytes(filePath, Bytes);
    }

    public void ReadFromFile(string filePath)
    {
        if (!File.Exists(filePath)) throw new FileNotFoundException("File does not exist.", filePath);
        _byteBuffer = File.ReadAllBytes(filePath);
        ResetPosition();
    }

    public void Compress()
    {
        using var memoryStream = new MemoryStream();
        using (var gzipStream = new GZipStream(memoryStream, CompressionMode.Compress))
        {
            gzipStream.Write(_byteBuffer, 0, _byteBuffer.Length);
        }
        _byteBuffer = memoryStream.ToArray();
        _position = _byteBuffer.Length;
    }

    public void Decompress()
    {
        using var memoryStream = new MemoryStream(_byteBuffer);
        using var gzipStream = new GZipStream(memoryStream, CompressionMode.Decompress);
        using var decompressedStream = new MemoryStream();
        gzipStream.CopyTo(decompressedStream);
        _byteBuffer = decompressedStream.ToArray();
        _position = _byteBuffer.Length;
    }

    public void WriteVarInt(int value)
    {
        while ((value & ~0x7F) != 0)
        {
            WriteByte((byte)((value & 0x7F) | 0x80));
            value >>= 7;
        }
        WriteByte((byte)(value & 0x7F));
    }

    public int ReadVarInt()
    {
        int result = 0;
        int shift = 0;
        int byteRead;
        do
        {
            byteRead = ReadByte();
            result |= (byteRead & 0x7F) << shift;
            shift += 7;
        } while ((byteRead & 0x80) != 0);
        return result;
    }

    public void WriteVarIntNoZigZag(int value)
    {
        while ((value & ~0x7F) != 0)
        {
            WriteByte((byte)((value & 0x7F) | 0x80));
            value >>= 7;
        }
        WriteByte((byte)(value & 0x7F));
    }

    public int ReadVarIntNoZigZag()
    {
        int result = 0;
        int shift = 0;
        int byteRead;
        do
        {
            byteRead = ReadByte();
            result |= (byteRead & 0x7F) << shift;
            shift += 7;
        } while ((byteRead & 0x80) != 0);
        return result;
    }

    public void WriteLong(long value)
    {
        EnsureCapacity(8);
        Array.Copy(BitConverter.GetBytes(value), 0, _byteBuffer, _position, 8);
        if (BitConverter.IsLittleEndian)
            Array.Reverse(_byteBuffer, _position, 8);
        _position += 8;
    }

    public long ReadLong()
    {
        if (_position + 8 > _byteBuffer.Length) throw new InvalidOperationException("Buffer overflow.");
        var value = _byteBuffer.Skip(_position).Take(8).ToArray();
        if (BitConverter.IsLittleEndian) Array.Reverse(value);
        _position += 8;
        return BitConverter.ToInt64(value, 0);
    }

    public void WriteVarLongZigZag(long value)
    {
        value = (value << 1) ^ (value >> 63);
        WriteVarLongNoZigZag(value);
    }

    public void WriteVarLongNoZigZag(long value)
    {
        while ((value & ~0x7F) != 0)
        {
            WriteByte((byte)((value & 0x7F) | 0x80));
            value >>= 7;
        }
        WriteByte((byte)(value & 0x7F));
    }

    public long ReadVarLongZigZag()
    {
        long result = ReadVarLongNoZigZag();
        return (result >> 1) ^ -(result & 1);
    }

    public long ReadVarLongNoZigZag()
    {
        long result = 0;
        int shift = 0;
        int byteRead;
        do
        {
            byteRead = ReadByte();
            result |= (byteRead & 0x7F) << shift;
            shift += 7;
        } while ((byteRead & 0x80) != 0);
        return result;
    }

    public void SetBit(int position, byte maskToSet)
    {
        if (position < _byteBuffer.Length)
        {
            Seek(position);
            byte current = ReadByte();
            Seek(position);
            current |= maskToSet;
            WriteByte(current);
        }
    }

    public void ClearBit(int position, byte maskToClear)
    {
        if (position < _byteBuffer.Length)
        {
            Seek(position);
            byte current = ReadByte();
            current &= (byte)~maskToClear;
            Seek(position);
            WriteByte(current);
        }
    }

    public bool CheckBit(int position, byte mask)
    {
        if (position < _byteBuffer.Length)
        {
            Seek(position);
            byte current = ReadByte();
            return (current & mask) == mask;
        }
        return false;
    }

    public byte GetBit(int position)
    {
        if (position < _byteBuffer.Length)
        {
            Seek(position);
            return ReadByte();
        }
        return 0;
    }

    public void Seek(int position)
    {
        if (position < 0 || position > _byteBuffer.Length)
            throw new ArgumentOutOfRangeException(nameof(position));
        _position = position;
    }

    public void InsertRandomBytes(int count)
    {
        Random rng = new Random();
        for (int i = 0; i < count; i++)
        {
            WriteByte((byte)rng.Next(256));
        }
    }
}
