package com.ninjabird.decathlon_check

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.widget.Toast
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationCompat.PRIORITY_MIN
import androidx.core.app.NotificationManagerCompat
import com.android.volley.Request
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import org.json.JSONObject
import java.io.File
import kotlin.random.Random


class SearchService: Service() {


    override fun onCreate() {
        super.onCreate()
        startForeground();
    }


    private fun startForeground() {
        Toast.makeText(this, "Cerco su Decathlon", Toast.LENGTH_SHORT).show()
        val service = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channelId =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    createNotificationChannel()
                } else {
                    ""
                }

        val notificationBuilder = NotificationCompat.Builder(this, channelId)
        val notification = notificationBuilder.setOngoing(true)
                .setSmallIcon(R.drawable.ic_stat_name)
                .setPriority(PRIORITY_MIN)
                .setCategory(Notification.CATEGORY_SERVICE)
                .setContentTitle("Cerco su Decathlon")
                .setContentText("Sto cercando su Decathlon i tuoi articoli")
                .build()
        startForeground(101, notification);
        getDataFromWebsite();
        stopSelf();
    }


    @RequiresApi(Build.VERSION_CODES.O)
    private fun createNotificationChannel(): String{
        val channelId = "my_service"
        val channelName = "My Background Service"
        val chan = NotificationChannel(channelId,
                channelName, NotificationManager.IMPORTANCE_HIGH);
        val pattern = longArrayOf(500, 500, 500, 500, 500, 500, 500, 500, 500)
        val alarmSound: Uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        val audioAttributes = AudioAttributes.Builder()
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                .build()
        chan.vibrationPattern=pattern;
        chan.setSound(alarmSound, audioAttributes);
        chan.lockscreenVisibility = Notification.VISIBILITY_PUBLIC
        val service = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        service.createNotificationChannel(chan)
        return channelId
    }


    override fun onBind(intent: Intent): IBinder? {
        return null
    }


    override fun onDestroy() {
        Toast.makeText(this, "Ricerca ultimata", Toast.LENGTH_SHORT).show()
    }


    private fun getDataFromStorage(): String{
        return try {
            val dir=baseContext.filesDir.path;
            File(dir.subSequence(0, dir.indexOf("/files")).toString() + "/app_flutter/linkData.bn").readText(Charsets.UTF_8);
        } catch (e: Exception) {
            Log.w("decathlon_check", "noFile");
            ""
        }
    }


    private fun convertDataToList(): MutableList<LinkData> {
        val data=getDataFromStorage();
        if(data!="") {
            val datas= mutableListOf<LinkData>();
            val string=data.substring(1, data.length - 1);
            val obj: List<String> =string.split("},");
            for(item in obj) {
                var itm=""
                if(!item.contains("}")) {
                    itm= "$item}";
                }
                else itm=item;
                datas.add(LinkDataFromJson(itm));
            }
            return datas;
        }
        else return mutableListOf();
    }


    private fun getHttp(item: LinkData) {
        val queue = Volley.newRequestQueue(this)

        val stringRequest = StringRequest(Request.Method.GET, item.link,
                { response ->
                    if (checkIfIsAvaiable(response)) {
                        pushNotification(item);
                    }
                    queue.stop();
                }, { error -> print(error); queue.stop(); });
        queue.add(stringRequest);
    }


    private fun LinkDataFromJson(data: String): LinkData {
        val obj=JSONObject(data);
        val linkData=LinkData();
        linkData.name=obj["name"].toString();
        linkData.link=obj["link"].toString();
        return linkData
    }


    private fun getDataFromWebsite() {
        val list=convertDataToList();
        for(item in list) {
            getHttp(item);
        }
    }


    private fun checkIfIsAvaiable(text: String) : Boolean{
        val start=text.indexOf("data-tnr-size-selector-stock-info");
        val end=text.indexOf("</span>", start);
        val substring=text.subSequence(start, end).toString();
        //val splitted = substring.split(">").toString();
        //val splitted2=splitted.split(" disponibil").toString();
        if(substring.contains("Disponibile")) return true;
        else return false;
    }


    private fun pushNotification(item: LinkData) {
        val alarmSound: Uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        val builder = NotificationCompat.Builder(this, "my_service")
                .setSmallIcon(R.drawable.ic_stat_name)
                .setContentTitle(item.name)
                .setContentText(item.name + " è disponibile")
                .setVibrate(longArrayOf(500, 500, 500, 500, 500, 500, 500, 500, 500))
                .setSound(alarmSound)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT);
        with(NotificationManagerCompat.from(this)) {
            notify(Random.nextInt(100, 10000), builder.build())
        }
    }
}


class LinkData {
    var name="";
    var link="";
}