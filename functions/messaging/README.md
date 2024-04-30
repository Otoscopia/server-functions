# Appwrite Messaging Function

This function is responsible for email and text notifications for various events in your application. It provides functionality for account creation, account validation, account deletion, new doctor's patient, new doctor's remarks, password reset, and enabling/disabling two-factor authentication.

## Prerequisites

Before using this function, make sure you have the following:

- An Appwrite backend server version 1.5.5 set up
- Appwrite SDK installed in your project
- SMTP server credentials for sending emails
- SMS gateway credentials for sending text messages

## Installation

1. Clone this repository:

  ```bash
  git clone https://github.com/Otoscopia/server-functions
  ```

1. Install the required dependencies:

  ```bash
  cd server-functions/messaging
  dart pub get
  ```

1. Configure the function:

- Open your appwrite console and navigate to `Messaging` section.
- Click on `Providers` section and create provider.
- Add your Email or SMS gateway credentials.
- Customize the email and text message templates in the `templates` directory to match your application's branding and content.

1. Deploy the function to your Appwrite server:

  ```bash
  appwrite functions createTag \
    --name messaging \
    --runtime dart-3.1 \
    --handler messaging.handler \
    --environment '{"APPWRITE_FUNCTION_PROJECT_ID":"your-project-id"}' \
    --tag latest \
    --code ./
  ```

## Usage

To use the messaging function, you can call it from your application whenever you need to send email or text notifications. Here's an example of how to use it:

```dart
class AppwriteMessaging {
  final Functions _function;

  AppwriteMessaging() : _function = Functions(client);

  Future<void> sendMessage({
    required String messageType = "password_reset",
    Map<String, dynamic> data,
  }) async {
    await _function.createExecution(
      functionId: Env.messaging,
      body: json.encode({"message_type": "password_reset", "data": data}),
      path: '/',
      method: ExecutionMethod.pOST,
    );
  }
}
```

## Contributing

Contributions are welcome! If you have any suggestions, bug reports, or feature requests, please open an issue or submit a pull request.
