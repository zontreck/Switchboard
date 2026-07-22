namespace LibSwitchboard.Args;

public class ArgumentParser
{

    /// <summary>
    /// Parses a string array of arguments.
    /// </summary>
    /// <param name="args">The string array of arguments to parse.</param>
    /// <returns>A arguments object representing the input</returns>
    public static Arguments Parse(string[] args)
    {
        Arguments ret = new Arguments();
        for (int i = 0; i < args.Length; i++)
        {
            var arg = args[i];
            if (arg.StartsWith("--"))
            {
                string key = arg.Substring(2);  // Remove the '--' part of the argument
                object? value = null;

                // Check if the argument has a value attached (either --arg=value or --arg value)
                if (i + 1 < args.Length && !args[i + 1].StartsWith("--"))
                {
                    value = args[i + 1];  // --arg value
                    i++;  // Skip the next argument as it is the value
                }
                else if (arg.Contains("="))
                {
                    value = arg.Substring(arg.IndexOf('=') + 1);  // --arg=value
                }

                // Determine the argument type and add it to the list
                if (int.TryParse(value?.ToString(), out var intValue))
                {
                    ret.AddArgument(new IntegerArgument(key, intValue));
                }
                else if (bool.TryParse(value?.ToString(), out var boolValue))
                {
                    ret.AddArgument(new BooleanArgument(key, boolValue));
                }
                else if (float.TryParse(value?.ToString(), out var floatValue))
                {
                    ret.AddArgument(new FloatArgument(key, floatValue));
                }
                else if (double.TryParse(value?.ToString(), out var doubleValue))
                {
                    ret.AddArgument(new DoubleArgument(key, doubleValue));
                }
                else
                {
                    // Default to StringArgument if no matching type is found
                    ret.AddArgument(new StringArgument(key, value?.ToString()));
                }
            }
        }

        return ret;
    }
}