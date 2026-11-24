import 'package:libac_dart/utils/TimeUtils.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';
import 'package:mysql_dart/mysql_dart.dart';

class Auditor {
  MySQLConnectionPool pool;
  Auditor({required this.pool});

  Future<void> log(
    UUID ID,
    String requestPath,
    String requestMethod,
    String requestHeaders,
    String requestData,
  ) async {
    int timestamp = TimeUtils.getUnixTimestamp();

    await pool.withConnection((conn) async {
      // Add the audit log entry
      await conn.execute(
        "INSERT INTO Audit (ID, RequestType, RequestPath, RequestData, Timestamp, RequestHeaders) VALUES (:id, :reqType, :path, :data, :ts, :headers);",
        {
          "id": ID.toString(),
          "reqType": requestMethod,
          "path": requestPath,
          "data": requestData,
          "ts": timestamp,
          "headers": requestHeaders,
        },
      );
    });
  }
}
