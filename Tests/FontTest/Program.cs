using System;
using System.Drawing;
using Svg;

namespace FontTest
{
	class Program
	{
		static void Main()
		{
			var svgPath = "lighttest.svg";
			var svgDoc = SvgDocument.Open(svgPath);

			// Register fonts declared in the <style> tag
			SvgFontHelper.HandleFontFaces(svgDoc, svgPath);

			/*	SvgFontManager.RegisterFont("FiraSans-Light", "FiraSans-Light.ttf", FontStyle.Regular);
				SvgFontManager.RegisterFont("FiraSans-Regular", "FiraSans-Regular.ttf", FontStyle.Regular);
				SvgFontManager.RegisterFont("FiraSans-Medium", "FiraSans-Medium.ttf", FontStyle.Regular);
				SvgFontManager.RegisterFont("FiraSans-Bold", "FiraSans-Bold.ttf", FontStyle.Bold);*/

			// Render
			var bmp = svgDoc.Draw();
			bmp.Save("output1.png");
			Console.WriteLine("SVG rendered to output.png");

		}
	}
}