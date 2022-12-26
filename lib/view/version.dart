import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:store_checker/store_checker.dart';
import 'package:trem_pocket/core/api.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionPage extends StatefulWidget {
  const VersionPage({Key? key}) : super(key: key);

  @override
  _VersionPage createState() => _VersionPage();
}

class _VersionPage extends State<VersionPage> {
  bool beta = false;
  String version = "";
  bool mainViewer = true;
  bool updateViewer = false;
  String lastVersion = "";
  String note = "";

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (packageInfo.version.split(".")[3].toString() != "0") beta = true;
      version = packageInfo.version;
      setState(() {});
    });
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
              width: double.infinity,
            ),
            Visibility(
              visible: mainViewer,
              child: Expanded(
                flex: 70,
                child: Material(
                  color: Colors.black,
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      border: Border.all(width: 3),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        alignment: const Alignment(0, 0),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/trem.png",
                                width: 150,
                                height: 150,
                              ),
                              const Text(
                                "TREM Pocket",
                                style: TextStyle(
                                    fontSize: 25, color: Colors.white),
                              ),
                              Text(
                                "$version | ${(beta) ? "開發版" : "穩定版"}",
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: !mainViewer && !updateViewer,
              child: Expanded(
                flex: 70,
                child: Material(
                  color: Colors.black,
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade900,
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      border: Border.all(width: 3),
                    ),
                    child: InkWell(
                      onTap: () {
                        Future.delayed(const Duration(milliseconds: 300), () {
                          updateViewer = true;
                        });
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        alignment: const Alignment(0, 0),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 40,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: double.infinity,
                                    ),
                                    Image.asset(
                                      "assets/images/trem.png",
                                      width: 150,
                                      height: 150,
                                    ),
                                    const Text(
                                      "TREM Pocket",
                                      style: TextStyle(
                                          fontSize: 25, color: Colors.white),
                                    ),
                                    Text(
                                      "$lastVersion | ${(beta) ? "開發版" : "穩定版"}",
                                      style: const TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              const Expanded(
                                flex: 3,
                                child: Text(
                                  "更新內容?",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: updateViewer,
              child: Expanded(
                flex: 70,
                child: Material(
                  color: Colors.black,
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade900,
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      border: Border.all(width: 3),
                    ),
                    child: InkWell(
                      onTap: () {
                        Future.delayed(const Duration(milliseconds: 300), () {
                          updateViewer = false;
                        });
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        alignment: const Alignment(0, 0),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.arrow_back_ios_outlined,
                                color: Colors.white,
                              ),
                              Expanded(
                                child: MarkdownWidget(
                                  data: note,
                                  styleConfig: StyleConfig(
                                      markdownTheme: MarkdownTheme.darkTheme),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              flex: 5,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (mainViewer) ? Colors.blue : Colors.green,
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                        //to set border radius to button
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () async {
                    if (mainViewer) {
                      var update = await updateChecker();
                      if (!update["update"]) {
                        const snackBar = SnackBar(
                          content: Text('當前已是最新版本!'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        note = update["note"];
                        lastVersion = update["lastVersion"];
                        mainViewer = false;
                      }
                    } else {
                      Source installationSource = await StoreChecker.getSource;
                      if (installationSource.toString() ==
                          "Source.IS_INSTALLED_FROM_LOCAL_SOURCE") {
                        await launch(
                            "https://exptech.com.tw/api/v1/file?path=/app-release.apk");
                      } else {
                        await launch(
                            "https://play.google.com/store/apps/details?id=com.exptech.trem_pocket");
                      }
                    }
                  },
                  child: Text(
                    (mainViewer) ? "檢查更新" : "前往更新",
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
