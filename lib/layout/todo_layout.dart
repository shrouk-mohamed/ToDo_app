import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';

import '../shared/components/components.dart';
import '../shared/cubit/cubit.dart';
import '../shared/cubit/state.dart';

class HomeLayout extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();
  HexColor primaryColor = HexColor("#307D7E");
  HexColor secondaryColor = HexColor("#C55FFC");
//#D2B4BC
//#C5908E
  @override
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..CreateDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates states) {
          if (states is AppInsertDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, AppStates states) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              backgroundColor: primaryColor,
              elevation: 0,
              title: Text(
                cubit.title[cubit.currentIndex],
              ), leading: const Icon(
              Icons.menu_book_rounded,
            ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              selectedItemColor: HexColor("#307D7E").withOpacity(0.9),
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              elevation: 49.0,
              //خلي واحده كظا علشان افتكر طريقه الاستدعاء التانيه (الكلام دا يخص السطر اللي حاي دا)
              currentIndex: AppCubit.get(context).currentIndex,
              onTap: (index) {
                AppCubit.get(context).changeIndex(index);
                //setState((){
                //currentIndex = index;
                //});
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.task,
                  ),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.check_circle_outline,
                  ),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.archive_outlined,
                  ),
                  label: 'Archived',
                ),
              ],
            ),
            body: ConditionalBuilder(
              condition: states is! AppGetDatabaseLoadingState,
              builder: (context) => cubit.screens[cubit.currentIndex],
              fallback: (context) =>
                  const Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: HexColor("#307D7E"),
              onPressed: () async {
                if (cubit.isBottomSheetShown) {
                  if (formKey.currentState!.validate()) {
                    cubit.insertToDateBase(
                        title: titleController.text,
                        time: timeController.text,
                        date: dateController.text);
                    //insertToDateBase(
                    //title: titleController.text,
                    //date: dateController.text,
                    //time: timeController.text,
                    //).then((value) {
                    //Navigator.pop(context);
                    //cubit.isBottomSheetShown = false;
                    // setState(() {fabIcon = Icons.edit;
                    //});
                    // });
                  }
                } else {
                  scaffoldKey.currentState
                      ?.showBottomSheet(
                        (context) => Container(
                          color: Colors.grey[200],
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  defaultFormField(
                                    controller: titleController,
                                    type: TextInputType.text,
                                    validate: (value) {
                                      if (value == null || value.isEmpty) {
                                        return ' title must not be empty';
                                      }
                                      return null;
                                    },
                                    label: 'Text Title',
                                    prefix: Icons.title,
                                  ),
                                  const SizedBox(
                                    height: 15.0,
                                  ),
                                  defaultFormField(
                                    controller: timeController,
                                    onTap: () {
                                      showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                          builder: (context, child) {
                                            return Theme(
                                              data: ThemeData.dark(),
                                              child: child!,
                                            );
                                          }).then((value) {
                                        timeController.text =
                                            value!.format(context).toString();
                                        print(value.format(context));
                                      });
                                    },
                                    validate: (value) {
                                      if (value == null || value.isEmpty) {
                                        return ' title must not be empty';
                                      }
                                      return null;
                                    },
                                    label: 'Task Time',
                                    type: TextInputType.datetime,
                                    prefix: Icons.watch_later_outlined,
                                  ),
                                  const SizedBox(
                                    height: 15.0,
                                  ),
                                  defaultFormField(
                                    controller: dateController,
                                    onTap: () {
                                      showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate:
                                              DateTime.parse('2023-10-03'),
                                          builder: (context, child) {
                                            return Theme(
                                              data: ThemeData.dark(),
                                              child: child!,
                                            );
                                          }).then((value) {
                                        dateController.text =
                                            DateFormat.yMMMd().format(value!);
                                        print(DateFormat.yMMMd().format(value));
                                      });
                                    },
                                    validate: (value) {
                                      if (value == null || value.isEmpty) {
                                        return ' date must not be empty';
                                      }
                                      return null;
                                    },
                                    label: 'Task Date',
                                    type: TextInputType.datetime,
                                    prefix: Icons.calendar_month_rounded,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        elevation: 20.0,
                      )
                      .closed
                      .then((value) {
                    cubit.changeBottomSheetState(
                      isShow: false,
                      icon: Icons.edit,
                    );
                  });

                  cubit.changeBottomSheetState(
                    isShow: true,
                    icon: Icons.add,
                  );
                }
              },
              child: Icon(
                cubit.fabIcon,
              ),
            ),
          );
        },
      ),
    );
  }
}
