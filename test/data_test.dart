import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libac_dart/utils/uuid/UUID.dart';
import 'package:switchboard/dart/octocon_format.dart';
import 'package:switchboard/globalHelpers.dart';

void main() {
  test("Make test data", () async {
    OctoconData testData = OctoconData();
    testData.alters.add(
      OctoAlterBuilder()
          .withID(id: 1)
          .withDescription(desc: "desc")
          .withName(name: "Test 1")
          .withPronouns(pronouns: "she/her")
          .build(),
    );
    testData.user = OctoconUser(
      id: UUID.generate(4),
      description: "test description",
      fields: [],
      username: "usertest",
      avatarUrl: "",
    );
    testData.fronts.add(
      OctoconFront(
        id: testData.user.id,
        comment: "",
        timeEnd: DateTime(1995),
        alterId: 1,
        timeStart: DateTime.now(),
      ),
    );

    File("test/test.json").writeAsStringSync(json.encode(testData.toJson()));

    expect(true, true); // This test cannot fail.
  });

  test("Import data test", () async {
    File tjson = File("test/test.json");
    OctoconData data = OctoconData.fromJson(await tjson.readAsString());

    expect(data.user.username, "usertest");
  });

  test("Get app version", () async {
    print(await SwitchboardConsts.getPackageVersion());

    expect(true, true);
  });
}
