
using System.Collections.Generic;

namespace LibSwitchboard.Args;


public static class ArgumentHelpers
{
    /// <summary>
    /// Generates a command-line help message for the provided arguments.
    /// </summary>
    /// <param name="arguments">The list of arguments to generate help for.</param>
    /// <returns>A string containing the help message.</returns>
    public static string GenerateHelpMessage(List<IArgument> arguments, string ProgramName)
    {
        StringBuilder helpMessage = new StringBuilder();
        helpMessage.Append($"Usage: {ProgramName} [options]\n");

        foreach (var arg in arguments)
        {
            string description = GetArgumentDescription(arg);
            string valueType = arg.GetValueType().ToString();
            helpMessage.Append($"  --{arg.Key} [{valueType}]  {description}\n");
        }

        return helpMessage.ToString();
    }

    /// <summary>
    /// Gets a description for an argument. This can be extended to provide more info.
    /// </summary>
    /// <param name="argument">The argument for which to generate a description.</param>
    /// <returns>A description of the argument.</returns>
    private static string GetArgumentDescription(IArgument argument)
    {
        // You can extend this to add more detailed descriptions for specific arguments
        return argument.HasValue() ? "Assigned value: " + argument.GetValue() : "No value assigned";
    }

    /// <summary>
    /// Retrieves the type of an argument in a human-readable format.
    /// </summary>
    /// <param name="argument">The argument to get the type for.</param>
    /// <returns>A string describing the argument type.</returns>
    private static string GetArgumentType(IArgument argument)
    {
        return argument.GetValueType() switch
        {
            ArgumentType.String => "string",
            ArgumentType.Integer => "integer",
            ArgumentType.Boolean => "boolean",
            ArgumentType.Float => "float",
            ArgumentType.Double => "double",
            _ => "unknown"
        };
    }
}