import 'package:flutter/material.dart';

class InfoButton extends StatelessWidget {
  const InfoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext ctx) {
                      return AlertDialog(
                          title: const Text("Pad de control"),
                          content: SizedBox(
                              width: 500,
                              height: 625,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    const Text(
                                        "Certains boutons de la télécommande peuvent être remplacés par des gestes sur le pad de control, pour une navigation plus rapide dans les applications de la freebox:"),
                                    ListView.separated(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      separatorBuilder:
                                          (BuildContext context, int index) =>
                                              const Divider(
                                                  height: 3,
                                                  color: Colors.grey),
                                      itemCount: 7,
                                      itemBuilder:
                                          (BuildContext context, int index) => [
                                        const ListTile(
                                          leading: Icon(Icons.arrow_forward),
                                          title: Text("glisser vers la droite"),
                                        ),
                                        const ListTile(
                                          leading: Icon(Icons.arrow_upward),
                                          title: Text("glisser vers le haut"),
                                        ),
                                        const ListTile(
                                          leading: Icon(Icons.arrow_back),
                                          title: Text("glisser vers la gauche"),
                                        ),
                                        const ListTile(
                                          leading: Icon(Icons.arrow_downward),
                                          title: Text("à vous de deviner"),
                                        ),
                                        const ListTile(
                                          leading: Text("OK"),
                                          title: Text("appui simple"),
                                        ),
                                        const ListTile(
                                          leading: Icon(
                                              Icons
                                                  .subdirectory_arrow_left_rounded,
                                              color: Colors.red),
                                          title: Text("appui long"),
                                        ),
                                        const ListTile(
                                          leading: Icon(
                                            Icons.menu_open,
                                            color: Colors.green,
                                          ),
                                          title: Text("double appui"),
                                        ),
                                      ][index],
                                    ),
                                    const Text(
                                        "Le bouton pour accéder à ce menu peut être désactivé dans les paramètres"),
                                    Row(children: [
                                      Expanded(child: Container()),
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                          },
                                          child: const Text("Ok"))
                                    ])
                                  ],
                                ),
                              )));
                    });
              },
            ),
            Expanded(child: Container())
          ],
        ),
        Expanded(child: Container())
      ],
    );
  }
}
