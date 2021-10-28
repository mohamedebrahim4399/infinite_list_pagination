import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_list_pagination/models/passengers_data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RefreshController refreshController =RefreshController(initialRefresh: true);
  List<Passenger> passengers = [];
  int currentPage = 1;
  late int totalPage;
  Future<bool> getPassengers({bool isRefresh = false}) async {
    if(isRefresh){
      currentPage =1;
    }else{
      if(currentPage >= totalPage){
        refreshController.loadNoData();
        return false;
      }
    }
    final Uri url = Uri.parse(
        'https://api.instantwebtools.net/v1/passenger?page=$currentPage&size=10');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final result = passengersDataFromJson(response.body);
      if(isRefresh){
        passengers = result.data;
      }else{
        passengers.addAll(result.data);
      }
      currentPage++;
      totalPage =result.totalPages;
      setState(() {});

      return true;
    }
    return false;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPassengers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite List Pagination'),
      ),
      body: SmartRefresher(
        controller: refreshController,
        enablePullUp: true,
        onRefresh: ()async{
          final result = await getPassengers(isRefresh: true);
          if(result){
            refreshController.refreshCompleted();
          }
          else{
            refreshController.refreshFailed();
          }
        },
        onLoading: ()async{
          final result = await getPassengers();
          if(result){
            refreshController.loadComplete();
          }
          else{
            refreshController.loadFailed();
          }
        },
        child: ListView.separated(
            itemBuilder: (context,index){
              var passenger = passengers[index];
              return ListTile(
                title:Text( passenger.name),
                subtitle: Text(passenger.airline[0].country),
                trailing: Text(passenger.airline[0].name),
              );
            },
            separatorBuilder: (context, index) {
              return const Divider();
            },
            itemCount: passengers.length),
      ),
    );
  }
}
