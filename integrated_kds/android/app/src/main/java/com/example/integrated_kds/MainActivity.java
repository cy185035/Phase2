package com.example.integrated_kds;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.bluetooth.BluetoothDevice;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;

import android.util.Log;
import android.widget.Toast;

import jpos.JposException;
import jpos.config.JposEntry;
import jpos.POSPrinter;
import jpos.POSPrinterConst;

import com.bxl.config.editor.BXLConfigLoader;

import io.flutter.embedding.android.FlutterActivity;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;


import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import java.util.List;
import java.util.Set;




public class MainActivity extends FlutterActivity {

    POSPrinter posPrinter;
    boolean openedPrinter = false;

    String address = "74:F0:7D:E7:DE:E0"; //mac address here
    String logicalName = "BLUETOOTH PRINTER";

    private static final String CHANNEL = "com.example.bix_flutter_integration/count";


    String ESCAPE_CHARACTERS = new String(new byte[] {0x1b, 0x7c});

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("printOrder")) {
                                printOrder(call.argument("name"), call.argument("modifiers"));
//                                if (count != -1) {
//                                    result.success(count);
//                                } else {
//                                    result.error("UNAVAILABLE", "Battery level not available.", null);
//                                }
                            } else {
                                result.notImplemented();
                            }
                        } ); }



    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        BXLConfigLoader bxlConfigLoader = new BXLConfigLoader(getApplicationContext());
        bxlConfigLoader.newFile();
        try {
            bxlConfigLoader.openFile();
        }
        catch (Exception e) {
            Log.d("nathan", "Exception 0");
            bxlConfigLoader.newFile();
        }

        try {
            Log.d("nathan", logicalName);
            bxlConfigLoader.addEntry(logicalName, BXLConfigLoader.DEVICE_CATEGORY_POS_PRINTER, BXLConfigLoader.PRODUCT_NAME_SRP_350PLUSIII, BXLConfigLoader.DEVICE_BUS_BLUETOOTH, address);
            bxlConfigLoader.saveFile();
        }
        catch (Exception e) {
            Log.d("nathan", e.toString());
        }
    }


    public void printOrder(String name, List<String> mods) {
        Log.d("nathan", "starting connection process");
        try {
            if(!openedPrinter) {
                posPrinter = new POSPrinter(getApplicationContext());
                Log.d("nathan", "log before print open");
                posPrinter.open(logicalName);
                posPrinter.claim(10000);
                posPrinter.setDeviceEnabled(true);
                posPrinter.setAsyncMode(true);
                openedPrinter = true;
            }
            //text print=
            posPrinter.markFeed(0);
            posPrinter.printNormal(POSPrinterConst.PTR_S_RECEIPT, name + "\n");
            posPrinter.printNormal(POSPrinterConst.PTR_S_RECEIPT, name + "\n");
            posPrinter.printNormal(POSPrinterConst.PTR_S_RECEIPT, name + "\n");
            posPrinter.printNormal(POSPrinterConst.PTR_S_RECEIPT, name + "\n");
            String temp = ESCAPE_CHARACTERS + "uC";
            System.out.prinln(temp.toString());
            posPrinter.printNormal(POSPrinterConst.PTR_S_RECEIPT, temp.toString() + name + "\n");
            for(int j = 0; j < mods.size(); j++) {
                posPrinter.printNormal(POSPrinterConst.PTR_S_RECEIPT, "      " + mods.get(j) + "\n");
            }
            posPrinter.cutPaper(90);

        }
        catch (JposException e) {
            Log.d("nathan", "encountered error 1");
            Log.d("nathan", e.toString());
        }
        catch (Exception e) {
            Log.d("nathan", "encountered error 2");
            Log.d("nathan", e.toString());
        }
    }
}