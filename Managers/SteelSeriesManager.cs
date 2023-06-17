using RGB.NET.Core;
using RGB.NET.Devices.SteelSeries;

namespace SteelSeriesApi.Managers
{
    public class SteelSeriesManager
    {
        readonly RGBSurface _surface;

        public SteelSeriesManager()
        {
            _surface = new RGBSurface();

            _surface.Load(SteelSeriesDeviceProvider.Instance);

            // Initialize the Device Provider and load all devices
            SteelSeriesDeviceProvider.Instance.Initialize(loadFilter: RGBDeviceType.Keyboard, throwExceptions: true);
            _surface.Attach(SteelSeriesDeviceProvider.Instance.Devices);

            // Perform a layout check and automatically update the surface
            _surface.AlignDevices();
        }

        public void SetLedColor(LedId ledId, Color color)
        {
            // SteelSeriesRGBDevice
            foreach (IRGBDevice steelSeriesKeyboard in _surface
                .Devices
                .Where(i => i.DeviceInfo.DeviceType == RGBDeviceType.Keyboard))
            {
                var led = steelSeriesKeyboard[ledId];
                if (led == null) continue;

                led.Color = color;
                steelSeriesKeyboard.Update(false);

                // Update the device and apply the color change
                //_surface.Update();
            }
        }
    }
}
