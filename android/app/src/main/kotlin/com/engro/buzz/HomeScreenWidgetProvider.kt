package com.engro.buzz

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

class HomeScreenWidgetProvider : HomeWidgetProvider() {
     override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {

                // Open App on Widget Click
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(context,
                        MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)

                val contacts = widgetData.getString("_contactList", "")

                var counterText = ""

                if (contacts != null) {
                    if (contacts.isEmpty()) {
                        counterText = "You have not pressed the counter button"
                    } else {
                        counterText = try {
                            val contactsList = JSONArray(contacts)
                            val stringBuilder = StringBuilder("Your contacts are:\n")
                            for (i in 0 until contactsList.length()) {
                                val contact = contactsList.getJSONObject(i)
                                stringBuilder.append("${contact["name"]}: ${contact["phoneNumber"]}\n")
                            }
                            stringBuilder.toString()
                        } catch (e: Exception) {
                            e.printStackTrace()
                            "Failed to parse contacts"
                        }
                    }
                }

                setTextViewText(R.id.tv_counter, counterText)

                // Pending intent to update counter on button click
                val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(context,
                        Uri.parse("myAppWidget://updatecounter"))
                setOnClickPendingIntent(R.id.bt_update, backgroundIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}