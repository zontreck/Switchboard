namespace LibSwitchboard.Args
{
    /// <summary>
    /// Argument class for String values.
    /// </summary>
    public class StringArgument : IArgument
    {
        public string Key { get; set; }
        private string? value;

        public StringArgument(string key, string? value = null)
        {
            Key = key;
            this.value = value;
        }

        public object? GetValue() => value;

        public ArgumentType GetValueType() => ArgumentType.String;

        public bool HasValue() => value != null;
        public bool required { get; set; }
    }

    /// <summary>
    /// Argument class for Integer values.
    /// </summary>
    public class IntegerArgument : IArgument
    {
        public string Key { get; set; }
        private int? value;

        public IntegerArgument(string key, int? value = null)
        {
            Key = key;
            this.value = value;
        }

        public object? GetValue() => value;

        public ArgumentType GetValueType() => ArgumentType.Integer;

        public bool HasValue() => value.HasValue;
        public bool required { get; set; }
    }

    /// <summary>
    /// Argument class for Boolean values.
    /// </summary>
    public class BooleanArgument : IArgument
    {
        public string Key { get; set; }
        private bool? value;

        public BooleanArgument(string key, bool? value = null)
        {
            Key = key;
            this.value = value;
        }

        public object? GetValue() => value;

        public ArgumentType GetValueType() => ArgumentType.Boolean;

        public bool HasValue() => value.HasValue;
        public bool required { get; set; }
    }

    /// <summary>
    /// Argument class for Float values.
    /// </summary>
    public class FloatArgument : IArgument
    {
        public string Key { get; set; }
        private float? value;

        public FloatArgument(string key, float? value = null)
        {
            Key = key;
            this.value = value;
        }

        public object? GetValue() => value;

        public ArgumentType GetValueType() => ArgumentType.Float;

        public bool HasValue() => value.HasValue;
        public bool required { get; set; }
    }

    /// <summary>
    /// Argument class for Double values.
    /// </summary>
    public class DoubleArgument : IArgument
    {
        public string Key { get; set; }
        private double? value;

        public DoubleArgument(string key, double? value = null)
        {
            Key = key;
            this.value = value;
        }

        public object? GetValue() => value;

        public ArgumentType GetValueType() => ArgumentType.Double;

        public bool HasValue() => value.HasValue;
        public bool required { get; set; }
    }
}
