// SvgFontHelper.cs
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;

namespace Svg
{
    public static class SvgFontHelper
    {
        public static void HandleFontFaces(SvgDocument doc, string svgFilePath)
        {
            var styleElements = doc.Descendants().OfType<SvgElement>()
                .Where(e => e.ElementName == "style");

            foreach (var style in styleElements)
            {
                var css = style.Content;
                var matches = Regex.Matches(css, @"@font-face\s*\{[^}]*\}");

                foreach (Match match in matches)
                {
                    var fontFace = match.Value;

                    var nameMatch = Regex.Match(fontFace, @"font-family:\s*[""']?([^;""']+)");
                    var srcMatch = Regex.Match(fontFace, @"src:\s*url\([""']?([^""')]+)[""']?\)");

                    if (nameMatch.Success && srcMatch.Success)
                    {
                        var fontName = nameMatch.Groups[1].Value.Trim();
                        var fontRelPath = srcMatch.Groups[1].Value.Trim();
                        var fontPath = Path.Combine(Path.GetDirectoryName(svgFilePath), fontRelPath);

                        SvgFontManager.RegisterFont(fontName, fontPath);
                    }
                }
            }
        }
    }
}
