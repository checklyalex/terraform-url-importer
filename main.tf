variable "checkly_api_key" {}
variable "checkly_account_id" {}

terraform {
  
  required_providers {
    checkly = {
      source = "checkly/checkly"
      version = "~> 1.0"
    }
  }
}

provider "checkly" {
  api_key = var.checkly_api_key
  account_id = var.checkly_account_id
}

locals {
  tier1 = toset(compact((split("\n", file("scripts/urls/tier1.txt") )))) //create as many tiers as required
  tier2 = toset(compact((split("\n", file("scripts/urls/tier2.txt") ))))
  tier3 = toset(compact((split("\n", file("scripts/urls/tier3.txt") ))))
}

resource "checkly_check_group" "tier-1-group" {
  name      = "Tier 1 URL's"
  activated = true
  muted     = false

 alert_settings {
    escalation_type = "RUN_BASED"

    run_based_escalation {
      failed_run_threshold      = 1
    }

    time_based_escalation {
      minutes_failing_threshold = 5
    }

    reminders {
      amount   = 2
      interval = 5
    }
  }

  locations = [
    "eu-west-1",
    "eu-central-1"
  ]

  concurrency               = 2
  double_check              = true
  use_global_alert_settings = true
}

resource "checkly_check_group" "tier-2-group" {
  name      = "Tier 2 URL's"
  activated = true
  muted     = false

 alert_settings {
    escalation_type = "RUN_BASED"

    run_based_escalation {
      failed_run_threshold      = 1
    }

    time_based_escalation {
      minutes_failing_threshold = 5
    }

    reminders {
      amount   = 2
      interval = 5
    }
  }

  locations = [
    "eu-west-1",
    "eu-central-1"
  ]

  concurrency               = 2
  double_check              = true
  use_global_alert_settings = true
}


resource "checkly_check" "tier1-check" {

  for_each                  = local.tier1 
  name                      = each.key
  type                      = "API"
  activated                 = true
  should_fail               = false
  frequency                 = 30
  double_check              = true
  use_global_alert_settings = true
  degraded_response_time    = 5000
  max_response_time         = 10000

  locations = [
    "us-west-1",
    "eu-central-1"
  ]

  group_id = checkly_check_group.tier-1-group.id

    request {
    url              = each.key
    follow_redirects = true

    assertion {
      source     = "STATUS_CODE"
      comparison = "EQUALS"
      target     = "200"
    }
  }
}

resource "checkly_check" "tier2-check" {

  for_each                  = local.tier2 
  name                      = each.key
  type                      = "API"
  activated                 = true
  should_fail               = false
  frequency                 = 30
  double_check              = true
  use_global_alert_settings = true
  degraded_response_time    = 5000
  max_response_time         = 10000

  locations = [
    "us-west-1",
    "eu-central-1"
  ]

  group_id = checkly_check_group.tier-2-group.id

    request {
    url              = each.key
    follow_redirects = true

    assertion {
      source     = "STATUS_CODE"
      comparison = "EQUALS"
      target     = "200"
    }
  }
}