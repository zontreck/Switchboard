namespace LibSwitchboard.Args
{
    public class StringBuilder
    {
        private string _buffer = string.Empty;

        public StringBuilder()
        {
        }

        public bool IsEmpty => string.IsNullOrEmpty(_buffer);

        public int Length => _buffer.Length;

        public void Append(string value)
        {
            _buffer += value;
        }

        public void Clear()
        {
            _buffer = string.Empty;
        }

        public override string ToString()
        {
            return _buffer;
        }
    }
}