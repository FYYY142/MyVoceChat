import 'package:flutter/material.dart';
import 'package:my_voce_chat/views/chat_views/chat_list_view.dart';
import 'package:my_voce_chat/views/todo_views/todo_view.dart';
import 'package:my_voce_chat/views/mine_views/mine_view.dart';

class TheHomeView extends StatefulWidget {
  const TheHomeView({super.key});

  @override
  State<TheHomeView> createState() => _TheHomeViewState();
}

class _TheHomeViewState extends State<TheHomeView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          ChatListView(),
          TodoView(),
          MineView(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        color: Colors.white,
        child: TabBar(
          controller: _tabController,
          indicator: const BoxDecoration(), // 去掉底部的跟随条
          tabs: const [
            Tab(icon: Icon(Icons.chat)),
            Tab(icon: Icon(Icons.calendar_month)),
            Tab(icon: Icon(Icons.person)),
          ],
        ),
      ),
    );
  }
}
