package com.ninjabird.decathlon_check

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.*
import android.util.Log
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {

    override fun onStart() {
        super.onStart();
        setAlarm();
        setReciver();
    }


    private  fun setAlarm() {
        val intent=Intent(this,SearchService::class.java);
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager;
        val pendingIntent = PendingIntent.getService(context, 1000, intent, PendingIntent.FLAG_CANCEL_CURRENT);


        alarmManager?.setInexactRepeating(
                AlarmManager.ELAPSED_REALTIME_WAKEUP,
                SystemClock.elapsedRealtime(),
                15*60*1000,
                pendingIntent
        )
    }


    private  fun setReciver() {
        val receiver = ComponentName(context, AlarmReceiver::class.java)

        context.packageManager.setComponentEnabledSetting(
                receiver,
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
        )
    }
}
