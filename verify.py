import pyotp

# Secret key stored in the database
secret_key = "PWTSGV4CKVPH6PPW"

# Generate an OTP based on the secret key
otp = pyotp.TOTP(secret_key)

# Prompt the user for OTP input
user_input = input("Enter the OTP: ")

# Verify the user-provided OTP
is_valid = otp.verify(user_input)

if is_valid:
    print("Authentication successful!")
else:
    print("Authentication failed!")
