#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_event.h"
#include "nvs_flash.h"
#include "esp_log.h"
#include "esp_nimble_hci.h"
#include "nimble/nimble_port.h"
#include "nimble/nimble_port_freertos.h"
#include "host/ble_hs.h"
#include "services/gap/ble_svc_gap.h"
#include "services/gatt/ble_svc_gatt.h"
#include "sdkconfig.h"
#include "driver/gpio.h"

char *TAG = "BLE-Server";
uint8_t ble_addr_type;
void ble_app_advertise(void);

#define BLINK_GPIO 2
static uint8_t s_led_state = 1;

//
void put_led( uint8_t value )
{
    /* Set the GPIO level according to the state (LOW or HIGH)*/
    gpio_set_level(BLINK_GPIO, value);
}

//
void blink_led(void)
{
    /* Set the GPIO level according to the state (LOW or HIGH)*/
    gpio_set_level(BLINK_GPIO, !s_led_state);
}

//configure gpio
static void configure_led(void)
{
    ESP_LOGI(TAG, "Example configured to blink GPIO LED!");
    gpio_reset_pin(BLINK_GPIO);
    /* Set the GPIO as a push/pull output */
    gpio_set_direction(BLINK_GPIO, GPIO_MODE_OUTPUT);
}

// Write data to ESP32 defined as server
static int device_write(uint16_t conn_handle, uint16_t attr_handle, struct ble_gatt_access_ctxt *ctxt, void *arg)
{
    // printf("Data from the client: %.*s\n", ctxt->om->om_len, ctxt->om->om_data);

    char * data = (char *)ctxt->om->om_data;
    printf("%d\n",strcmp(data, (char *)"LIGHT ON")==0);
    if (strcmp(data, (char *)"LIGHT ON\0")==0)
    {
       printf("LIGHT ON\n");
    }
    else if (strcmp(data, (char *)"LIGHT OFF\0")==0)
    {
        printf("LIGHT OFF\n");
    }
    else if (strcmp(data, (char *)"FAN ON\0")==0)
    {
        printf("FAN ON\n");
    }
    else if (strcmp(data, (char *)"FAN OFF\0")==0)
    {
        printf("FAN OFF\n");
    }
    else{
        printf("Data from the client: %.*s\n", ctxt->om->om_len, ctxt->om->om_data);
    }
    
    
    return 0;
}

// Read data from ESP32 defined as server
static int device_read(uint16_t con_handle, uint16_t attr_handle, struct ble_gatt_access_ctxt *ctxt, void *arg)
{
    os_mbuf_append(ctxt->om, "Data from the server", strlen("Data from the server"));
    return 0;
}

// my function for transmit battery values
static int tx_batteryStatus(uint16_t con_handle, uint16_t attr_handle, struct ble_gatt_access_ctxt *ctxt, void *arg)
{
    static uint8_t i = 0;
    char * msgBatt  = "<batteryLevel=0.50><limitSet=0.95><remainingKm=1000><remainingMinutes=1000><temperature=25><soc=88><soh=90>";
    char * msgBatt2 = "<batteryLevel=0.75><limitSet=0.80><remainingKm=1000><remainingMinutes=1000><temperature=50><soc=87><soh=95>";
    if( (i++)%2 == 0){
        os_mbuf_append(ctxt->om, msgBatt, strlen(msgBatt));
    }
    else{
        os_mbuf_append(ctxt->om, msgBatt2, strlen(msgBatt2));
    }
    return 0;
}

// my function for transmit inside values
static int tx_insideStatus(uint16_t con_handle, uint16_t attr_handle, struct ble_gatt_access_ctxt *ctxt, void *arg)
{
    static uint8_t i = 0;
    char * msgIns  = "<tempSetPoint=22.5><airSpeed=1><tempHVAC=21>";
    char * msgIns2  = "<tempSetPoint=18><airSpeed=3><tempHVAC=18>";
    blink_led();
    if( (i++)%2 == 0){
        os_mbuf_append(ctxt->om, msgIns, strlen(msgIns));
    }
    else{
        os_mbuf_append(ctxt->om, msgIns2, strlen(msgIns2));
    }
    return 0;
}

// Write data to ESP32 defined as server
static int rx_security(uint16_t conn_handle, uint16_t attr_handle, struct ble_gatt_access_ctxt *ctxt, void *arg)
{
    
    char * data = (char *)ctxt->om->om_data;
    printf("%s\n",data);
    if ( strcmp(data, (char *) "LOCKED\0" ) == 0 )
    {
        //printf("LIGHT ON\n");
        s_led_state = 1 ;
        put_led(s_led_state);
    }
    else if (strcmp(data, (char *)"UNLOCKED\0")==0)
    {
        //printf("LIGHT OFF\n");
        s_led_state = 0 ;
        put_led(s_led_state);
    }
    
    return 0;
}

// Array of pointers to other service definitions
// UUID - Universal Unique Identifier
static const struct ble_gatt_svc_def gatt_svcs[] = {
    {.type = BLE_GATT_SVC_TYPE_PRIMARY,
     .uuid = BLE_UUID16_DECLARE(0x180),                 // Define UUID for device type
     .characteristics = (struct ble_gatt_chr_def[]){
         {.uuid = BLE_UUID16_DECLARE(0xFEF4),           // Define UUID for reading
          .flags = BLE_GATT_CHR_F_READ,
          .access_cb = device_read},
         {.uuid = BLE_UUID16_DECLARE(0xDEAD),           // Define UUID for writing
          .flags = BLE_GATT_CHR_F_WRITE,
          .access_cb = device_write},
        //
        {.uuid = BLE_UUID16_DECLARE(0xBA77),           // Define UUID for battery
          .flags = BLE_GATT_CHR_F_READ,
          .access_cb = tx_batteryStatus},
        //
        {.uuid = BLE_UUID16_DECLARE(0xF0F0),           // Define UUID for inside
          .flags = BLE_GATT_CHR_F_READ,
          .access_cb = tx_insideStatus},
        //
        {.uuid = BLE_UUID16_DECLARE(0xFAFA),           // Define UUID for security
          .flags = BLE_GATT_CHR_F_WRITE,
          .access_cb = rx_security},
        //



        {0}}},
    {0}};

// BLE event handling
static int ble_gap_event(struct ble_gap_event *event, void *arg)
{
    switch (event->type)
    {
    // Advertise if connected
    case BLE_GAP_EVENT_CONNECT:
        ESP_LOGI("GAP", "BLE GAP EVENT CONNECT %s", event->connect.status == 0 ? "OK!" : "FAILED!");
        if (event->connect.status != 0)
        {
            ble_app_advertise();
        }
        break;
    // Advertise again after completion of the event
    case BLE_GAP_EVENT_DISCONNECT:
        ESP_LOGI("GAP", "BLE GAP EVENT DISCONNECTED");
        if (event->connect.status != 0)
        {
            ble_app_advertise();
        }
        break;
    case BLE_GAP_EVENT_ADV_COMPLETE:
        ESP_LOGI("GAP", "BLE GAP EVENT");
        ble_app_advertise();
        break;
    default:
        break;
    }
    return 0;
}

// Define the BLE connection
void ble_app_advertise(void)
{
    // GAP - device name definition
    struct ble_hs_adv_fields fields;
    const char *device_name;
    memset(&fields, 0, sizeof(fields));
    device_name = ble_svc_gap_device_name(); // Read the BLE device name
    fields.name = (uint8_t *)device_name;
    fields.name_len = strlen(device_name);
    fields.name_is_complete = 1;
    ble_gap_adv_set_fields(&fields);

    // GAP - device connectivity definition
    struct ble_gap_adv_params adv_params;
    memset(&adv_params, 0, sizeof(adv_params));
    adv_params.conn_mode = BLE_GAP_CONN_MODE_UND; // connectable or non-connectable
    adv_params.disc_mode = BLE_GAP_DISC_MODE_GEN; // discoverable or non-discoverable
    ble_gap_adv_start(ble_addr_type, NULL, BLE_HS_FOREVER, &adv_params, ble_gap_event, NULL);
}

// The application
void ble_app_on_sync(void)
{
    ble_hs_id_infer_auto(0, &ble_addr_type); // Determines the best address type automatically
    ble_app_advertise();                     // Define the BLE connection
}

// The infinite task
void host_task(void *param)
{
    
    nimble_port_run(); // This function will return only when nimble_port_stop() is executed
}

void app_main()
{


    nvs_flash_init();                          // 1 - Initialize NVS flash using
    // esp_nimble_hci_and_controller_init();      // 2 - Initialize ESP controller
    nimble_port_init();                        // 3 - Initialize the host stack
    //ble_svc_gap_device_name_set("BLE-Server"); // 4 - Initialize NimBLE configuration - server name
    ble_svc_gap_device_name_set("BLE-EvServer"); // 4 - Initialize NimBLE configuration - server name
    ble_svc_gap_init();                        // 4 - Initialize NimBLE configuration - gap service
    ble_svc_gatt_init();                       // 4 - Initialize NimBLE configuration - gatt service
    ble_gatts_count_cfg(gatt_svcs);            // 4 - Initialize NimBLE configuration - config gatt services
    ble_gatts_add_svcs(gatt_svcs);             // 4 - Initialize NimBLE configuration - queues gatt services.
    ble_hs_cfg.sync_cb = ble_app_on_sync;      // 5 - Initialize application
    
    /* Configure the peripheral according to the LED type */
    configure_led();
    put_led(s_led_state);
    nimble_port_freertos_init(host_task);      // 6 - Run the thread
}
