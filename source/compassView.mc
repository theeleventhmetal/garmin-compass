import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Sensor;

class compassView extends WatchUi.View {

    var headingAvailable = false;
    var currentHeadingDegrees = 0.0;
    var pollTimer = Timer.Timer;

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        Sensor.enableSensorEvents(method(:onSensorData) as Method(sensorInfo as Sensor.Info) as Void);
        pollTimer = new Timer.Timer();
        pollTimer.start(method(:checkSensorReady), 200, true);
    }

    function onSensorData(sensorInfo as Sensor.Info) as Void {
        if (sensorInfo.heading != null){
            headingAvailable = true;
            currentHeadingDegrees = sensorInfo.heading * 180.0 / Math.PI;
            updateHands();
        }
    }

    function checkSensorReady() as Void {
        if (headingAvailable) {
            pollTimer.stop();
            return;
        }
        var info = Sensor.getInfo();
        if (info != null && info.heading != null) {
            headingAvailable = true;
            currentHeadingDegrees = info.heading * 180.0 / Math.PI;
            updateHands();
            pollTimer.stop();
        } else {
            System.println("Waiting for compass...");
        }
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    function updateHands() as Void {
        setClockHandPosition({
            :clockState => WatchUi.ANALOG_CLOCK_STATE_HOLDING,
            :hour => currentHeadingDegrees
        });
        System.println("updating hand position");
        WatchUi.requestUpdate();
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
