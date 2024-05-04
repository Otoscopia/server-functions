import 'dart:io';

// Appwrite Client environment variables
final String projectEndpoint = Platform.environment["APPWRITE_ENDPOINT"]!;
final String projectID = Platform.environment["APPWRITE_PROJECT"]!;
final String api = Platform.environment["API"]!;

final String databaseID = Platform.environment["DATABASE"]!;
final String usersCollection = Platform.environment["USER_COLLECTION"]!;

final String adminId = Platform.environment["ADMIN_ID"]!;
final String adminName = Platform.environment["ADMIN_NAME"]!;
final String adminEmail = Platform.environment["ADMIN_EMAIL"]!;

const disclaimer = """
<p>Otoscopia Team</p>

<p>
    <i>
      <b>Disclaimer:</b> This communication is intended solely for the use of the addressee. It may contain confidential or legally privileged information. If you are not the intended recipient, any disclosure, copying, distribution or taking any action in reliance on this communication is strictly prohibited and may be unlawful. If you received this communication in error, please notify the sender immediately and delete this communication from your system. Otoscopia is neither liable for the proper and complete transmission of this communication nor for any delay in its receipt.
    </i>
  </p>
""";

String kUserVerified(
  String userName,
) =>
    """
<html>
  <p>Dear <b>$userName</b>,</p>

  <p>Your Otoscopia User Profile has been verified!</p>

  <p>We are looking forward to working with you. You may access your account via the Web, Desktop or the Mobile Application.</p>

  <p>Sincerely,</p>

  $disclaimer
</html>
""";

String kNewUserAccountAdmin(
  String adminName,
  String userId,
  String userRole,
) =>
    """
<html>
  <p>Dear admin <b>$adminName</b>,</p>

  <p>A new account has been created with the id of <b>$userId</b> and role of <b>$userRole</b>. Please verify the account status so that they can continue with the application.</p>
</html>
""";

String kNewUserAccountClient(
  String userName,
  String adminEmail,
) =>
    """
<html>
  <p>Dear <b>$userName</b>,</p>

  <p>Thank you for creating your User Profile! You are halfway in opening your Otoscopia account with Otoscopia Team.</p>

  <p>We are excited to have you on board and we are looking forward to working with you. We will be in touch with you soon to discuss the next steps. In the meantime, if you have any questions, please feel free to reach out to us at $adminEmail.</p>

  Thank you and we look forward to welcoming you to the Otoscopia family.</p>

  <p>Sincerely,</p>

  $disclaimer
</html>
""";
String kNewPatient(
  String doctorName,
  String patientCode,
) =>
    """
<html>
  <p>Dear Doctor <b>$doctorName</b>,</p>

<p>A new patient has been <b>added</b> to your list with the following code: <i>$patientCode</i>. Please log in to your Otoscopia account to view the patient's details and to schedule an appointment with the patient if necessary.</p>

<p>Thank you and we look forward to the successful treatment of the patient.</p>

  <p>Sincerely,</p>

  $disclaimer
</html>
""";

String kDeleteAccountAdmin(
  String adminName,
  String userName,
  String userId,
  String userEmail,
) =>
    """
<html>
  <p>Dear admin <b>$adminName</b>,</p>

  <p>User <b>$userName</b> has requested to delete their account with the id of $userId, Please verify if their account can be delete and notify the user with their email $userEmail.</p>
</html>
""";

String kDeleteAccountClient(
  String userName,
) =>
    """
<html>
  <p>Dear <b>$userName</b>,</p>

  <p>You have requested to delete your account, Please wait for the admin response before to delete your account.</p>

  <p>Sincerely,</p>

  $disclaimer
</html>
""";

String kNewRemarks(
  String nurseName,
  String patientCode,
) =>
    """
<html>
  <p>Dear Nurse <b>$nurseName</b>,</p>

<p>Your patient with the following code: <i>$patientCode</i> and its medical record has been <b>updated</b>. Please log in to your Otoscopia account to view the patient's details along with the updated medical record. Please take necessary action if required and update the patients guardian about the status of the patient.</p>

<p>Thank you and we look forward to the successful treatment of the patient.</p>

  <p>Sincerely,</p>

  $disclaimer
</html>
""";

String kResetPassword(
  String userName,
) =>
    """
<html>
  <p>Dear <b>$userName</b>,</p>

  <p>You have modified your password, If you haven't change your password, please <a href="mailto:laurencetroyv@gmail.com, laurencetroy.valdez@g.msuiit.edu.ph">contact theadmin</a> via email.</p>

  <p>Sincerely,</p>

  $disclaimer
</html>
""";
