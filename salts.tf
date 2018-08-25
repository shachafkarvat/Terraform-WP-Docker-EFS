# resource "random_string" "password" {
#   length = 16
#   special = true
#   override_special = "/@\" "
# }

# resource "aws_db_instance" "example" {
#   password = "${random_string.password.result}"
# }

resource "random_string" "AUTH_KEY" {
  length  = 16
  special = true

  #   override_special = "/@\" "
}

resource "random_string" "SECURE_AUTH_KEY" {
  length  = 24
  special = true

  # override_special = "/@\" "
}

resource "random_string" "LOGGED_IN_KEY" {
  length  = 24
  special = true

  # override_special = "/@\" "
}

resource "random_string" "NONCE_KEY" {
  length  = 24
  special = true

  # override_special = "/@\" "
}

resource "random_string" "AUTH_SALT" {
  length  = 24
  special = true

  # override_special = "/@\" "
}

resource "random_string" "SECURE_AUTH_SALT" {
  length  = 24
  special = true

  # override_special = "/@\" "
}

resource "random_string" "LOGGED_IN_SALT" {
  length  = 24
  special = true

  # override_special = "/@\" "
}

resource "random_string" "NONCE_SALT" {
  length  = 24
  special = true

  # override_special = "/@\" "
}
