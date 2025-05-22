var svgPath = "lighttest.svg";
var svgDoc = SvgDocument.Open(svgPath);

// Register fonts declared in the <style> tag
SvgFontHelper.HandleFontFaces(svgDoc, svgPath);

// Render
var bmp = svgDoc.Draw();
bmp.Save("output.png");