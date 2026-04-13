import 'package:hive_ce/hive_ce.dart';
import 'package:linknote/features/search/data/datasource/search_history_local_datasource.dart';
import 'package:linknote/features/search/data/datasource/search_remote_datasource.dart';
import 'package:linknote/features/search/data/repository/search_repository_impl.dart';
import 'package:linknote/features/search/domain/repository/i_search_repository.dart';
import 'package:linknote/features/search/domain/usecase/search_links_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'search_di_providers.g.dart';

@riverpod
SearchRemoteDataSource searchRemoteDataSource(Ref ref) {
  return SearchRemoteDataSource(Supabase.instance.client);
}

@riverpod
SearchHistoryLocalDataSource searchHistoryLocalDataSource(Ref ref) {
  return SearchHistoryLocalDataSource(Hive.box<String>('search_history'));
}

@riverpod
ISearchRepository searchRepository(Ref ref) {
  return SearchRepositoryImpl(ref.watch(searchRemoteDataSourceProvider));
}

@riverpod
SearchLinksUsecase searchLinksUsecase(Ref ref) {
  return SearchLinksUsecase(ref.watch(searchRepositoryProvider));
}
