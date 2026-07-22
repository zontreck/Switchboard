using System;
using System.Collections.Generic;

namespace LibSwitchboard.Args
{
    /// <summary>
    /// Represents a collection of arguments.
    /// </summary>
    public class Arguments
    {
        /// <summary>
        /// The dictionary containing argument names and their corresponding <see cref="IArgument"/> instances.
        /// </summary>
        private readonly Dictionary<string, IArgument> _arguments;

        /// <summary>
        /// Returns the total number of stored arguments
        /// </summary>
        public int Count => _arguments.Count;

        /// <summary>
        /// Initializes a new instance of the <see cref="Arguments"/> class.
        /// </summary>
        public Arguments()
        {
            _arguments = new Dictionary<string, IArgument>(StringComparer.OrdinalIgnoreCase);
        }

        /// <summary>
        /// Adds an argument to the collection.
        /// </summary>
        /// <param name="argument">The argument to add.</param>
        /// <exception cref="ArgumentException">Thrown if an argument with the same key already exists.</exception>
        internal void AddArgument(IArgument argument)
        {
            if (_arguments.ContainsKey(argument.Key))
                throw new ArgumentException($"An argument with the key '{argument.Key}' already exists.");

            _arguments[argument.Key] = argument;
        }

        /// <summary>
        /// Retrieves an argument by its key.
        /// </summary>
        /// <param name="key">The key of the argument to retrieve.</param>
        /// <returns>The <see cref="IArgument"/> associated with the key.</returns>
        /// <exception cref="KeyNotFoundException">Thrown if the key is not found in the collection.</exception>
        public IArgument GetArgument(string key)
        {
            if (!_arguments.TryGetValue(key, out var argument))
                throw new KeyNotFoundException($"No argument found with the key '{key}'.");

            return argument;
        }

        /// <summary>
        /// Checks if an argument with the specified key exists in the collection.
        /// </summary>
        /// <param name="key">The key to check for.</param>
        /// <returns><c>true</c> if an argument with the key exists; otherwise, <c>false</c>.</returns>
        public bool HasArg(string key)
        {
            return _arguments.ContainsKey(key); // Dictionary method remains unchanged
        }

        /// <summary>
        /// Removes an argument from the collection by its key.
        /// </summary>
        /// <param name="key">The key of the argument to remove.</param>
        /// <returns><c>true</c> if the argument was removed; otherwise, <c>false</c>.</returns>
        public bool RemoveArgument(string key)
        {
            return _arguments.Remove(key);
        }

        /// <summary>
        /// Gets all arguments in the collection.
        /// </summary>
        /// <returns>An enumerable of all <see cref="IArgument"/> instances in the collection.</returns>
        public IEnumerable<IArgument> GetAllArguments()
        {
            return _arguments.Values;
        }

        /// <summary>
        /// Clears all arguments from the collection.
        /// </summary>
        public void Clear()
        {
            _arguments.Clear();
        }



    }

    public class ArgumentBuilder
    {
        private readonly Arguments _arguments;

        public ArgumentBuilder()
        {
            _arguments = new Arguments();
        }

        /// <summary>
        /// Adds a predefined argument for a string type.
        /// </summary>
        public ArgumentBuilder withStringArgument(string key, string? value = null, bool required = false)
        {
            IArgument arg = new StringArgument(key, value);
            arg.required = required;
            _arguments.AddArgument(arg);
            return this;
        }

        /// <summary>
        /// Adds a predefined argument for an integer type.
        /// </summary>
        public ArgumentBuilder withIntegerArgument(string key, int? value = null, bool required = false)
        {
            IArgument arg = new IntegerArgument(key, value);
            arg.required = required;
            _arguments.AddArgument(arg);
            return this;
        }

        /// <summary>
        /// Adds a predefined argument for a boolean type.
        /// </summary>
        public ArgumentBuilder withBooleanArgument(string key, bool? value = null, bool required = false)
        {
            IArgument arg = new BooleanArgument(key, value);
            arg.required = required;
            _arguments.AddArgument(arg);
            return this;
        }

        /// <summary>
        /// Adds a predefined argument for a float type.
        /// </summary>
        public ArgumentBuilder withFloatArgument(string key, float? value = null, bool required = false)
        {

            IArgument arg = new FloatArgument(key, value);
            arg.required = required;
            _arguments.AddArgument(arg);
            return this;
        }

        /// <summary>
        /// Adds a predefined argument for a double type.
        /// </summary>
        public ArgumentBuilder withDoubleArgument(string key, double? value = null, bool required = false)
        {

            IArgument arg = new DoubleArgument(key, value);
            arg.required = required;
            _arguments.AddArgument(arg);
            return this;
        }

        /// <summary>
        /// Adds a predefined 'help' argument (usually a flag).
        /// </summary>
        public ArgumentBuilder withHelpArgument()
        {
            _arguments.AddArgument(new BooleanArgument("help", false)); // or true based on logic
            return this;
        }

        /// <summary>
        /// Adds a predefined 'version' argument.
        /// </summary>
        public ArgumentBuilder withVersionArgument()
        {
            _arguments.AddArgument(new BooleanArgument("version"));
            return this;
        }

        /// <summary>
        /// Returns the constructed Arguments object containing all the added arguments.
        /// </summary>
        public Arguments Build()
        {
            return _arguments;
        }
    }
}
