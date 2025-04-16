variable "database_name" {
  type        = string
  description = "The name of the Timestream database"
  default     = "environment-db"
}

variable "table_name" {
  type        = string
  description = "The name of the Timestream table"
  default     = "environment"
}

variable "iot_thing" {
  type        = string
  description = "The name of the IoT thing"
  default     = "JanneRaspberryPi3"
}

variable "topic_name" {
  type        = string
  description = "The name of the IoT topic"
  default     = "iot/environment"
}
