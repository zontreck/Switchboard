namespace LibSwitchboard.Args
{
    /// <summary>
    /// Defines the base interface for an argument.
    /// </summary>
    public interface IArgument
    {
        /// <summary>
        /// Gets the unique key identifying the argument.
        /// The setter is private to ensure immutability outside the implementing class.
        /// </summary>
        string Key { get; set; }

        /// <summary>
        /// Obtains the value of the argument.
        /// </summary>
        /// <returns>The value of the argument as an object, or null if no value is present.</returns>
        object? GetValue();

        /// <summary>
        /// Gets the type of the value this argument holds.
        /// </summary>
        /// <returns>The <see cref="ArgumentType"/> of the argument value.</returns>
        ArgumentType GetValueType();

        /// <summary>
        /// Indicates whether this argument has a value assigned.
        /// </summary>
        /// <returns><c>true</c> if the argument has a value; otherwise, <c>false</c>.</returns>
        bool HasValue();

        /// <summary>
        /// For CLI Help only. Indicates whether the argument is required or not
        /// </summary>
        bool required { set; }
    }

    /// <summary>
    /// Defines the types of arguments supported.
    /// </summary>
    public enum ArgumentType
    {
        String,
        Integer,
        Boolean,
        Float,
        Double
    }
}