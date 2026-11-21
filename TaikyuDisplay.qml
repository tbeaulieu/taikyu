import QtQuick 2.3
import QtGraphicalEffects 1.0

// .----------------------------------------------------------------------.
// |                                                                      |
// |                                                                      |
// |          _/_/_/  _/    _/  _/_/_/    _/_/_/_/  _/_/_/                |
// |       _/        _/    _/  _/    _/  _/        _/    _/               |
// |        _/_/    _/    _/  _/_/_/    _/_/_/    _/_/_/                  |
// |           _/  _/    _/  _/        _/        _/    _/                 |
// |    _/_/_/      _/_/    _/        _/_/_/_/  _/    _/                  |
// |    _/_/_/_/_/          _/  _/                            _/  _/      |
// |       _/      _/_/_/      _/  _/    _/    _/  _/    _/  _/  _/       |
// |      _/    _/    _/  _/  _/_/      _/    _/  _/    _/  _/  _/        |
// |     _/    _/    _/  _/  _/  _/    _/    _/  _/    _/                 |
// |    _/      _/_/_/  _/  _/    _/    _/_/_/    _/_/_/  _/  _/          |
// |                                       _/                             |
// |                                  _/_/                                |
// |                                                                      |
// |                                                                      |
// '----------------------------------------------------------------------'



Item {
    id: root
    ////////// IC7 LCD RESOLUTION ////////////////////////////////////////////
    width: 800
    height: 480
    
    z: 0
    
    property int myyposition: 0
    property int udp_message: rpmtest.udp_packetdata

    property bool udp_up: udp_message & 0x01
    property bool udp_down: udp_message & 0x02
    property bool udp_left: udp_message & 0x04
    property bool udp_right: udp_message & 0x08

    property int membank2_byte7: rpmtest.can203data[10]
    property int inputs: rpmtest.inputsdata

    //Inputs//31 max!!
    property bool ignition: inputs & 0x01
    property bool battery: inputs & 0x02
    property bool lapmarker: inputs & 0x04
    property bool rearfog: inputs & 0x08
    property bool mainbeam: inputs & 0x10
    property bool up_joystick: inputs & 0x20 || root.udp_up
    property bool leftindicator: inputs & 0x40
    property bool rightindicator: inputs & 0x80
    property bool brake: inputs & 0x100
    property bool oil: inputs & 0x200
    property bool seatbelt: inputs & 0x400
    property bool sidelight: inputs & 0x800
    property bool tripresetswitch: inputs & 0x1000
    property bool down_joystick: inputs & 0x2000 || root.udp_down
    property bool doorswitch: inputs & 0x4000
    property bool airbag: inputs & 0x8000
    property bool tc: inputs & 0x10000
    property bool abs: inputs & 0x20000
    property bool mil: inputs & 0x40000
    property bool shift1_id: inputs & 0x80000
    property bool shift2_id: inputs & 0x100000
    property bool shift3_id: inputs & 0x200000
    property bool service_id: inputs & 0x400000
    property bool race_id: inputs & 0x800000
    property bool sport_id: inputs & 0x1000000
    property bool cruise_id: inputs & 0x2000000
    property bool reverse: inputs & 0x4000000
    property bool handbrake: inputs & 0x8000000
    property bool tc_off: inputs & 0x10000000
    property bool left_joystick: inputs & 0x20000000 || root.udp_left
    property bool right_joystick: inputs & 0x40000000 || root.udp_right

    property int odometer: rpmtest.odometer0data/10 //Overridden by Taikyu.qml: km or miles to match speedunits, div by 10 to get 6 digits
    property int tripmeter: rpmtest.tripmileage0data*0.621371
    property real value: 0
    property real shiftvalue: 0

    property real rpm: rpmtest.rpmdata
    property real rpmlimit: 8000 //Originally was 7k, switched to 8000 -t
    property real rpmdamping: 5
    property real speed: rpmtest.speeddata
    property int speedunits: 2

    property real watertemp: rpmtest.watertempdata
    property real waterhigh: 0
    property real waterlow: 80
    property real waterunits: 1

    property real fuel: rpmtest.fueldata
    property real fuelhigh: 0
    property real fuellow: 0
    property real fuelunits
    property real fueldamping

    property real o2: rpmtest.o2data      // lambda
    property real afrlow: 0               // AFR, 0 = no rich warning
    property real afrhigh: 0              // AFR, 0 = no lean warning
    property int afrunits: 1              // 0 = show lambda, 1 = show AFR
    property int afrshow: 0               // 1 = show the AFR readout
    property int oiltempshow: 0           // 1 = show the oil temp readout
    property int oilpressureshow: 0       // 1 = show the oil pressure readout
    readonly property real afr: o2 * 14.7
    // Oil pressure Low is bar (the sender value is bar); 0 = no warning
    readonly property bool oilpressureOk: oilpressurelow === 0 || oilpressure >= oilpressurelow
    readonly property bool afrWarn: (afrhigh > 0 && afr > afrhigh) || (afrlow > 0 && afr < afrlow)
    property real map: rpmtest.mapdata
    property real maf: rpmtest.mafdata

    property real oilpressure: rpmtest.oilpressuredata
    property real oilpressurehigh: 0
    property real oilpressurelow: 0
    property real oilpressureunits: 0

    property real oiltemp: rpmtest.oiltempdata
    property real oiltemphigh: 90
    property real oiltemplow: 90
    property real oiltempunits: 1

    property real batteryvoltage: rpmtest.batteryvoltagedata

    property int mph: Math.round(speed * 0.621371)

    property int gearpos: rpmtest.geardata

    property real speed_spring: 1
    property real speed_damping: 1

    property real rpm_needle_spring: 3.0 //if(rpm<1000)0.6 ;else 3.0
    property real rpm_needle_damping: 0.2 //if(rpm<1000).15; else 0.2

    property bool changing_page: rpmtest.changing_pagedata

    // Set by Taikyu.qml (same hooks as the AgeSolo template)
    property string settingsFocus: ""   // key of the setting being edited, "" when the menu is closed
    property string userColor: ""       // Red/Green/Blue from the settings menu

    property string white_color: "#FFFFFF"
    property string primary_color: "#000000"; //#FFBF00 for amber
    property string night_light_color: "#ACFAFF"  //Pale Indiglo Blue
    property string sweetspot_color: "#FFA500" //Cam Changeover Rev colpr
    property string warning_red: "#C60000" //Redline/Warning colors
    property string nightlight_pink: "#F85653"
    property string nightlight_orange: "#F89553"
    property string engine_warmup_color: "#eb7500"
    property string background_color: "#000000"
    property string soft_bkg_color: "#222222"

    x: 0
    y: 0

    //Fonts
    FontLoader {
        id: twentytwosegment
        source: "./fonts/22Segment.ttf"
    }

    //Peak Values

    property int peak_rpm: 0
    property int peak_speed: 0
    property int peak_water: 0
    property int peak_oil: 0
    property bool car_movement: false

    onRpmChanged: if (rpm > peak_rpm) peak_rpm = rpm

    onSpeedChanged: {
        if (speed > peak_speed) peak_speed = speed
        if (speed > 10 && !car_movement) car_movement = true
    }

    onWatertempChanged: if (watertemp > peak_water) peak_water = watertemp

    onOiltempChanged: if (oiltemp > peak_oil) peak_oil = oiltemp
   
    //Utility  
    function easyFtemp(degreesC){
        return ((((degreesC.toFixed(0))*9)/5)+32).toFixed(0)
    }
    
    function getPeakSpeed(){
        if (root.speedunits === 0) return root.peak_speed.toFixed(0); else return (root.peak_speed*.621371).toFixed(0)
    }

    function getTemp(fluid){
        if(fluid == "COOLANT"){
            if(root.seatbelt && root.car_movement && root.speed === 0){ 
                 if(root.waterunits !== 1)
                    return easyFtemp(root.peak_water) + "F"
                else 
                    return root.peak_water.toFixed(0) + "C"
            }
            else{
                if(root.waterunits !== 1)
                    return easyFtemp(root.watertemp) + "F"
                else 
                    return root.watertemp.toFixed(0) + "C"
            }
        }
        else{
            if(root.seatbelt && root.car_movement && root.speed === 0){
                 if(root.oiltempunits !== 1)
                    return easyFtemp(root.peak_oil) 
                else 
                    return root.peak_oil.toFixed(0) + "C"
            }
            else{
                if(root.oiltempunits !== 1)
                    return easyFtemp(root.oiltemp) 
                else 
                    return root.oiltemp.toFixed(0) + "C"
            }
        }
    }

    function getGear(){
        switch(rpmtest.geardata){
            case 0:
                return 'n'
            case 1:
                return 1
            case 2:
                return 2
            case 3:
                return 3
            case 4:
                return 4
            case 5:
                return 5
            case 6:
                return 6
            case 10:
                return 'r'
            default:
                return '-'
        }
    }

    // Plain ES5 only (var, no template strings, no padStart): the IC7's QML engine
    // does not support the newer syntax.
    function hex2(n) {
        var h = Math.round(n).toString(16);
        return h.length < 2 ? "0" + h : h;
    }

    function interpolateColor(rpm, startRpm, endRpm, startColor, endColor) {
        // Ensure RPM is within bounds
        var progress = Math.max(0, Math.min(1, (rpm - startRpm) / (endRpm - startRpm)));

        // Convert hex colors to RGB
        var startR = parseInt(startColor.slice(1, 3), 16);
        var startG = parseInt(startColor.slice(3, 5), 16);
        var startB = parseInt(startColor.slice(5, 7), 16);

        var endR = parseInt(endColor.slice(1, 3), 16);
        var endG = parseInt(endColor.slice(3, 5), 16);
        var endB = parseInt(endColor.slice(5, 7), 16);

        // Interpolate RGB values
        var r = hex2(startR + (endR - startR) * progress);
        var g = hex2(startG + (endG - startG) * progress);
        var b = hex2(startB + (endB - startB) * progress);

        // Return hex color
        return "#" + r + g + b;
    }

    Rectangle {
        id: background_rect
        x: 0   
        y: 0
        width: 800
        height: 480
        color: root.background_color
        border.width: 0
        z: 0
    }
    Rectangle {
        id: rpm_thing
        x: 0
        y: 70
        z: 4
        height: 188
        width: root.rpm <= 5000 ? 30 + (root.rpm * 0.049) : (root.rpm * 0.1) - 224
        property color currentColor: root.rpm < 7500 ? 
            interpolateColor(root.rpm, 4500, 5000, 
                !root.sidelight ? root.white_color : night_light_color, 
                !root.sidelight ? root.sweetspot_color : root.nightlight_orange) :
            interpolateColor(root.rpm, 7500, 8000, 
                !root.sidelight ? root.sweetspot_color : root.nightlight_orange, 
                !root.sidelight ? root.warning_red : root.nightlight_pink)
        color: currentColor
        Behavior on color {
            ColorAnimation { duration: 50 }  // Smooth over one frame
        }
    }
    Item{
        id: rpm_line
        x: if(root.rpm <= 5000){28 + (root.rpm * 0.049)} else{
            (root.rpm * 0.1) - 225
        }
        opacity: 0
        y:70;z:9
        Rectangle{
            height: 188; width: 4
            color: root.white_color
        }
    }
    Image{
        x:0; y:0; z: 10
        id: rpm_line_mask
        source: !root.sidelight ? './img/tach-marker-mask.png' : './img/indiglo/tach-marker-mask.png'
        opacity:0
    } 
    Image{
        id: tach_mask 
        x:0; y:0; z:8
        source: './img/tach-mask.png'
    }
    Image{
        id: tach_outlines
        x: 28; y: 70; z: 11;
        source: if(!root.sidelight) './img/tach-outlines.png'; else './img/indiglo/tach-outlines.png'
        opacity: 0;
    }  
    Image{
        id: red_zone
        x: 576;y:70;z:1
        source: './img/red-zone.png'
    }

    
    Timer{
        interval:0; running:root.ignition; repeat: false
        onTriggered: first_step.start()
    }
    
    ParallelAnimation{
        id: first_step
        NumberAnimation{
            target: tach_outlines; property: "opacity"; from: 0.00; to: 1.0; duration: 1000
        }
    }
    Timer{
        interval: 1000; running:root.ignition; repeat: false
        onTriggered: second_step.start()
    }
    ParallelAnimation{
        id: second_step
        NumberAnimation{
                target: rpm_line_mask; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
            }
        
        NumberAnimation{
            target: speed_text; property: "opacity"; from: 0.00; to: 1.00; duration: 1000;
        }
        NumberAnimation{
            target: gear_display_char; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
        NumberAnimation{
            target: rpm_display; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
        NumberAnimation{
            target: rpm_display; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
        NumberAnimation{
            target: speed_teller; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
        NumberAnimation{
            target: gear_label; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
    }

    Timer{
        interval: 1500; running: root.ignition; repeat: false
        onTriggered: third_step.start()
    }
    ParallelAnimation{
        id: third_step
        NumberAnimation{
            target: divider; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
        NumberAnimation{
            target: coolant_temp_display; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
        NumberAnimation{
            target: fuel_level_display; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
        NumberAnimation{
                target: rpm_line; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
            }
    }
    Timer{
        interval: 2000; running: root.ignition; repeat: false
        onTriggered: fourth_step.start()
    }
    ParallelAnimation{
        id: fourth_step
        NumberAnimation{
            target: optional_inputs; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
    }
    Timer{
            interval: 2500; running: root.ignition; repeat: false
            onTriggered: fifth_step.start()
        }
    ParallelAnimation{
        id: fifth_step
        NumberAnimation{
            target: cool_coolant_bar; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
        NumberAnimation{
            target: hot_coolant_bar; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
        NumberAnimation{
            target: coolant_soft_bkg; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
        NumberAnimation{
            target: fuel_bar; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
        NumberAnimation{
            target: fuel_soft_bkg; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
    }
    Image{
        id: divider
        x: 20; y:277; z: 4
        opacity: 0
        source: if(!root.sidelight) './img/divider.png'; else './img/indiglo/divider.png'
    }
    Item{
        z:12
        property string speedtext: if(root.peak_speed === 0 && root.rpm === 0) "Push Start Button"; else "Peak Speed "+ getPeakSpeed() + "   Peak RPM " + root.peak_rpm
            property string spacing: "   "
            property string combined: speedtext + spacing
            property string display: combined.substring(step) + combined.substring(0, step)
            property int step: 0
            Timer {
                interval: 250
                running: true
                repeat: true
                onTriggered: parent.step = (parent.step + 1) % parent.combined.length
            }
        Text{
            id: speed_text
            x: 567; y: 165; z: 11
            width: 208
            font.family: twentytwosegment.name
            font.italic: true
            font.pixelSize: 100
            horizontalAlignment: Text.AlignRight
            color: if(!root.sidelight) root.white_color; else night_light_color
            renderType: Text.NativeRendering
            opacity: 0
            clip: true
                text: if((root.speed === 0 && !root.car_movement && root.rpm === 0) || (root.speed === 0 && root.seatbelt && root.car_movement)){
                        parent.display
                    }
                    else{
                        if (root.speedunits === 0) root.speed.toFixed(0); else (root.speed*.621371).toFixed(0)
                    }
        }
    }
    Text{
        id: speed_text_bkg
        x: 621; y: 165; z: 11
        width: 152
        font.family: twentytwosegment.name
        font.italic: true
        font.pixelSize: 100
        horizontalAlignment: Text.AlignRight
        color: "#222222"
        text: "@@@"
        renderType: Text.NativeRendering
    }
    Image{
        id: speed_teller
        x: 726; y:250; z: 11
        opacity: 0
        source: if (root.speedunits === 0){
                    if(!root.sidelight)'./img/kmh.png'
                    else './img/indiglo/kmh.png'
                    }
                else {
                    if(!root.sidelight)'./img/mph.png'
                    else './img/indiglo/mph.png'
                    }
    }
    Item{
        id: rpm_display
        z: 14
        opacity: 0
        Text{
            color: "#000000"
            text: root.rpm
            font.family: twentytwosegment.name
            font.bold: false
            font.pixelSize: 30
            renderType: Text.NativeRendering
            x: 640; y: 132; z:17
            horizontalAlignment: Text.AlignRight
            width: 85
        }
        Image{
            x:586; y: 130; z:16
            visible: if(root.rpm < root.rpmlimit) true; else false
            source: if(!root.sidelight)'./img/rpm-container.png'; else './img/indiglo/rpm-container.png'
        }
        Image{
            id: rpm_container_blink
            x:586; y: 130; z:16
            visible: if(root.rpm >= root.rpmlimit) true; else false
            source: if(!root.sidelight)'./img/rpm-container-warning.png'; else './img/indiglo/rpm-container-warning.png'
            SequentialAnimation {
                id: shiftBlinkAnimation
                running: root.rpm >= root.rpmlimit
                loops: Animation.Infinite
                
                NumberAnimation {
                    target: rpm_container_blink
                    property: "opacity"
                    to: 100
                    duration: 50
                }
                NumberAnimation {
                    target: rpm_container_blink
                    property: "opacity"
                    to: 0
                    duration: 50
                }
            }
        }
        
    }
    Item{
        id: geardisplay
        z: 11
        Text{
            id: gear_display_char
            z:2
            font.family: twentytwosegment.name
            font.bold: false
            font.pixelSize: 144
            x: 354; y: 125
            text: getGear()
            color: if(!root.sidelight) root.white_color; else night_light_color
            renderType: Text.NativeRendering
            opacity: 0
        }
        Text{
            z:1
            font.family: twentytwosegment.name
            font.bold: false
            font.pixelSize: 144
            x: 354; y: 125
            text: '@'
            color: "#222222"
            renderType: Text.NativeRendering
        }
        Image{
            id: gear_label
            opacity: 0
            source:if(!root.sidelight) './img/gear.png'; else './img/indiglo/gear.png'
            x: 373; y: 250; z:2
        }
    }


    Item{
         id: coolant_temp_display
        opacity: 0        
        Image{
            //124 px high
            source:if(!root.sidelight) './img/coolant-mask.png'; else  './img/indiglo/coolant-mask.png'
            x: 20; y:312; z: 4

        }
        Rectangle{
            id: cool_coolant_bar
            x: 20
            y: if (root.watertemp <= 100)432 - ((root.watertemp.toFixed(0) - 20) * 1.2125); else 335
            z:3
            color: if(!root.sidelight) root.white_color; else root.night_light_color
            width: 116 
            opacity: 0
            height: if (root.watertemp <= 100)(root.watertemp.toFixed(0) - 20) * 1.2125; else 97
        }
        Rectangle{
            id: hot_coolant_bar
            x: 20
            y:if (root.watertemp <= 120) 432 - ((root.watertemp - 20) * 1.2); else 313
            color: if(!root.sidelight) root.warning_red; else root.nightlight_pink
            width: 116;
            opacity: 0
            height:if (root.watertemp <= 120)(root.watertemp - 20) * 1.2; else 119
            z:2
        }
        Rectangle{
            id: coolant_soft_bkg
            opacity: 0
            x:20; y: 313; z: 1
            height: 119; width: 116
            color: root.soft_bkg_color
        }
        Text{
            x: 42; y: 440
            font.family: twentytwosegment.name
            font.bold: false
            font.pixelSize: 30
            renderType: Text.NativeRendering
            color: if(root.waterhigh === 0 || root.watertemp.toFixed(0) < root.waterhigh){
                if(!root.sidelight) root.white_color; else root.night_light_color}
                else{
                    if(!root.sidelight) root.warning_red; else root.nightlight_pink
                }
            text: getTemp("COOLANT")
            horizontalAlignment: Text.AlignRight
            width:58
        }
    }
    Item{
        id: fuel_level_display
        opacity: 0
        Image{
            source:if(!root.sidelight) './img/fuel-mask.png'; else  './img/indiglo/fuel-mask.png'
            x: 672; y: 312;
            z: 3
        }
        Rectangle{
            id: fuel_bar
            x: 672
            y: 432 - (root.fuel * 1.19)
            width: 116 
            height: root.fuel * 1.19
            opacity: 0
            color: if (root.fuel > 30){
                    if(!root.sidelight) root.white_color; else root.night_light_color
                }else{
                    if(!root.sidelight) root.warning_red; else root.nightlight_pink
                }
            z:2
        }
        Rectangle{
            id: fuel_soft_bkg
            opacity: 0
            x:672; y: 313; z: 1
            height: 119; width: 116
            color: root.soft_bkg_color
        }

    }
    Item{
        id: optional_inputs
        opacity: 0
        Item{
            id: oil_pressure_group
            visible: root.oilpressureshow === 1
            Image{
                source: if(!root.sidelight) './img/info-stripe.png'; else './img/indiglo/info-stripe.png'
                x: 150; y: 310; z:2;
            }
            Image{
                source: if(!root.sidelight) './img/oil-press.png'; else './img/indiglo/oil-press.png'
                x:152;y:333;z:2;
            }
            Text{
                x:280; y: 315; z:2
                width: 93
                font.family: twentytwosegment.name
                font.bold: false
                font.pixelSize: 48
                renderType: Text.NativeRendering
                horizontalAlignment: Text.AlignRight
                text: if(root.oilpressureunits === 1) root.oilpressure.toFixed(1); else (root.oilpressure.toFixed(1) * 14.504).toFixed(0)
                color: if(root.oilpressureOk){
                    if(!root.sidelight) root.white_color; else root.night_light_color}
                    else{
                        if(!root.sidelight) root.warning_red; else root.nightlight_pink
                    }
            }
            Text{
                x:280; y: 315; z:1
                width: 93
                font.family: twentytwosegment.name
                font.bold: false
                font.pixelSize: 48
                renderType: Text.NativeRendering
                horizontalAlignment: Text.AlignRight
                text: "1@@@"
                color: root.soft_bkg_color
            }
        }
        Item{
            id: oil_temp_group
            visible: root.oiltempshow === 1
            Image{
                source: if(!root.sidelight) './img/info-stripe.png'; else './img/indiglo/info-stripe.png'
                x: 150; y: 380; z:2;
            }
            Image{
                source: if(!root.sidelight) './img/oil-temp.png'; else './img/indiglo/oil-temp.png'
                x:152;y:400;z:2;
            }
            Text{
                x:280; y: 383; z:2
                width: 93
                font.family: twentytwosegment.name
                font.bold: false
                font.pixelSize: 48
                renderType: Text.NativeRendering
                horizontalAlignment: Text.AlignRight
                text: getTemp("OIL")
                color: if(root.oiltemphigh === 0 || root.oiltemp.toFixed(0) < root.oiltemphigh){
                    if(!root.sidelight) root.white_color; else root.night_light_color}
                    else{
                        if(!root.sidelight) root.warning_red; else root.nightlight_pink
                    }
            }
            Text{
                x:280; y: 383; z:1
                width: 93
                font.family: twentytwosegment.name
                font.bold: false
                font.pixelSize: 48
                renderType: Text.NativeRendering
                horizontalAlignment: Text.AlignRight
                text: "1@@@"
                color: root.soft_bkg_color
            }
        }
        Item{
            id: afr_group
            visible: root.afrshow === 1
            Image{
                source: if(!root.sidelight) './img/info-stripe.png'; else './img/indiglo/info-stripe.png'
                x: 423; y: 310; z:2;
            }
            Image{
                source: if(!root.sidelight) './img/afr.png'; else './img/indiglo/afr.png'
                x:425;y:333;z:2;
            }
            Text{
                x:552; y: 315; z:2
                width: 93
                font.family: twentytwosegment.name
                font.bold: false
                font.pixelSize: 48
                renderType: Text.NativeRendering
                horizontalAlignment: Text.AlignRight
                // lambda in, shown as AFR (x 14.7) or lambda; red outside the AFR limits
                text: root.afrunits === 1 ? root.afr.toFixed(1) : root.o2.toFixed(2)
                color: if(!root.afrWarn){
                    if(!root.sidelight) root.white_color; else root.night_light_color}
                    else{
                        if(!root.sidelight) root.warning_red; else root.nightlight_pink
                    }
            }
            Text{
                x:552; y: 315; z:1
                width: 93
                font.family: twentytwosegment.name
                font.bold: false
                font.pixelSize: 48
                renderType: Text.NativeRendering
                horizontalAlignment: Text.AlignRight
                text: "1@@@"
                color: root.soft_bkg_color
            }
        }
    }
    Text{ 
        id: odometer
        x: 671; y: 450
        width: 77
        color: if(!root.sidelight) root.white_color; else root.night_light_color
        font.family: twentytwosegment.name
        font.bold: false
        font.pixelSize: 20
        renderType: Text.NativeRendering
        horizontalAlignment: Text.AlignRight
        // Taikyu.qml already hands this over in km (KMH) or miles (MPH / BOTH)
        text: root.odometer
    }
    Image{
        x: 751; y:453;
        source: if (root.speedunits === 0){
            if(!root.sidelight) './img/km.png'; else './img/indiglo/km.png'
        }else{
            if(!root.sidelight) './img/mi.png'; else './img/indiglo/mi.png'
        }
    }
    Item{
        id: idiot_lights
        Image{
            x: 346; y: 440
            width: 33; height: 34 
            z: 1
            source: "./img/warning-lights/gas-light.png"
            visible: root.fuel < root.fuellow
        }
        Image{
            x: 308; y: 440
            width: 33; height: 34 
            z: 1
            source: "./img/warning-lights/oil-light.png"
            visible: root.oil
        }
        Image{
            x: 270; y: 440
            width: 33; height: 34 
            z: 1
            source: "./img/warning-lights/brake-light.png"
            visible: root.brake || root.handbrake
        }
        Image{
            x: 233; y: 440
            width: 33; height: 34 
            z: 1
            source: "./img/warning-lights/seatbelt-light.png"
            visible: root.seatbelt
        }
        Image{
            x: 195; y: 440
            width: 33; height: 34 
            z: 1
            source: "./img/warning-lights/blinker-light.png"
            visible: root.leftindicator || root.rightindicator
        }
        Image{
            x:573; y: 440
             width: 33; height: 34 
            z: 1
            source: "./img/warning-lights/checkengine-light.png"
            visible: root.mil
        }
        Image{
            x:498; y: 440
            width: 33; height: 34 
            z: 1
            source: "./img/warning-lights/battery-light.png"
            visible: root.battery
        }
        Image{
            x:535.5; y: 440
            width: 33; height: 34 
            z: 1
            source: "./img/warning-lights/door-light.png"
            visible: root.doorswitch
        }
        Image{
            x:460; y: 440
            width: 33; height: 34 
            z: 1
            source: "./img/warning-lights/airbag-light.png"
            visible: root.airbag
        }
        Image{
            x:422; y: 440
            width: 33; height: 34 
            z: 1
            source: "./img/warning-lights/hibeams-light.png"
            visible: root.mainbeam
        }
        Image{
            x:384; y: 440
            width: 33; height: 34 
            z: 1
            source: "./img/warning-lights/abs-light.png"
            visible: root.abs
        }
    }

    /* ########################################################################## */
    /* Settings focus: marks the readout that the settings menu is editing        */
    /* ########################################################################## */
    // settingsFocus is the key of the selected menu row ("waterhigh", "rpmlimit", ...)
    // or "" when the menu is closed / browsing groups.
    readonly property int focusSpot: {
        var k = root.settingsFocus
        if (k === "waterunits" || k === "waterhigh") return 0
        if (k === "oilpressureshow" || k === "oilpressureunits" || k === "oilpressurelow") return 1
        if (k === "oiltempshow" || k === "oiltempunits" || k === "oiltemphigh") return 2
        if (k === "afrshow" || k === "afrunits" || k === "afrhigh" || k === "afrlow") return 3
        if (k === "fuellow") return 4
        if (k === "speedunits") return 5
        if (k === "rpmlimit") return 6
        return -1
    }
    property real focusPulse: 1

    SequentialAnimation {
        running: root.focusSpot >= 0
        loops: Animation.Infinite
        onRunningChanged: if (!running) root.focusPulse = 1
        NumberAnimation { target: root; property: "focusPulse"; to: 0.3; duration: 500; easing.type: Easing.InOutSine }
        NumberAnimation { target: root; property: "focusPulse"; to: 1;   duration: 500; easing.type: Easing.InOutSine }
    }

    Rectangle {
        id: settings_focus_box
        // x, y, width, height: coolant, oil pressure, oil temp, AFR, fuel, speed, rpm readout
        readonly property var spots: [
            [ 12, 304, 132, 172],
            [142, 302, 254,  69],
            [142, 372, 254,  69],
            [415, 302, 254,  69],
            [664, 304, 132, 136],
            [556, 166, 236, 108],
            [578, 122, 202,  46]
        ]
        property int spot: 0
        Connections {
            target: root
            onFocusSpotChanged: if (root.focusSpot >= 0) settings_focus_box.spot = root.focusSpot   // keep the last spot while fading out
        }
        x: spots[spot][0]
        y: spots[spot][1]
        width: spots[spot][2]
        height: spots[spot][3]
        radius: 6
        z: 30
        color: "transparent"
        border.width: 8
        border.color: "#000000"
        opacity: root.focusSpot >= 0 ? root.focusPulse : 0
        visible: opacity > 0
        Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            radius: 4
            color: "transparent"
            border.width: 4
            border.color: "#ffd400"         // menu yellow; nothing else on this dash uses it
        }
    }
}//End Taikyu Dash

