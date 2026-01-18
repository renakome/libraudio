import 'package:flutter_modular/flutter_modular.dart';
import 'data/datasources/radio_datasource_impl.dart';
import 'data/repositories/radio_repository_impl.dart';
import 'domain/repositories/radio_repository.dart';
import 'data/datasources/radio_datasource.dart';
import 'presenter/controllers/radio_controller.dart';
import 'presenter/pages/radio_page.dart';

class RadioModule extends Module {
  @override
  void binds(i) {
    i.add<RadioDataSource>(RadioDataSourceImpl.new);
    i.add<RadioRepository>(RadioRepositoryImpl.new);
    i.add(RadioController.new);
  }

  @override
  void routes(r) {
    r.child('/radio', child: (context) => const RadioPage());
  }
}
