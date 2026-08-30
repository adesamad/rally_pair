// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fd_rally_pair_database.dart';

// ignore_for_file: type=lint
class $PlaySessionRecordsTable extends PlaySessionRecords
    with TableInfo<$PlaySessionRecordsTable, PlaySessionRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaySessionRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courtCountMeta = const VerificationMeta(
    'courtCount',
  );
  @override
  late final GeneratedColumn<int> courtCount = GeneratedColumn<int>(
    'court_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pairingPolicyMeta = const VerificationMeta(
    'pairingPolicy',
  );
  @override
  late final GeneratedColumn<String> pairingPolicy = GeneratedColumn<String>(
    'pairing_policy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scorePresetMeta = const VerificationMeta(
    'scorePreset',
  );
  @override
  late final GeneratedColumn<String> scorePreset = GeneratedColumn<String>(
    'score_preset',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _matchFormatMeta = const VerificationMeta(
    'matchFormat',
  );
  @override
  late final GeneratedColumn<String> matchFormat = GeneratedColumn<String>(
    'match_format',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _singleGameMeta = const VerificationMeta(
    'singleGame',
  );
  @override
  late final GeneratedColumn<bool> singleGame = GeneratedColumn<bool>(
    'single_game',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("single_game" IN (0, 1))',
    ),
  );
  static const VerificationMeta _avoidRecentPartnerMeta =
      const VerificationMeta('avoidRecentPartner');
  @override
  late final GeneratedColumn<bool> avoidRecentPartner = GeneratedColumn<bool>(
    'avoid_recent_partner',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("avoid_recent_partner" IN (0, 1))',
    ),
  );
  static const VerificationMeta _randomSeedMeta = const VerificationMeta(
    'randomSeed',
  );
  @override
  late final GeneratedColumn<int> randomSeed = GeneratedColumn<int>(
    'random_seed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextPlayerIdMeta = const VerificationMeta(
    'nextPlayerId',
  );
  @override
  late final GeneratedColumn<int> nextPlayerId = GeneratedColumn<int>(
    'next_player_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextMatchIdMeta = const VerificationMeta(
    'nextMatchId',
  );
  @override
  late final GeneratedColumn<int> nextMatchId = GeneratedColumn<int>(
    'next_match_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextQueueOrderMeta = const VerificationMeta(
    'nextQueueOrder',
  );
  @override
  late final GeneratedColumn<int> nextQueueOrder = GeneratedColumn<int>(
    'next_queue_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pairingRoundMeta = const VerificationMeta(
    'pairingRound',
  );
  @override
  late final GeneratedColumn<int> pairingRound = GeneratedColumn<int>(
    'pairing_round',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completionOrderMeta = const VerificationMeta(
    'completionOrder',
  );
  @override
  late final GeneratedColumn<int> completionOrder = GeneratedColumn<int>(
    'completion_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultRotationModeMeta =
      const VerificationMeta('defaultRotationMode');
  @override
  late final GeneratedColumn<String> defaultRotationMode =
      GeneratedColumn<String>(
        'default_rotation_mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('winnerStays'),
      );
  static const VerificationMeta _nextGroupIdMeta = const VerificationMeta(
    'nextGroupId',
  );
  @override
  late final GeneratedColumn<int> nextGroupId = GeneratedColumn<int>(
    'next_group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    courtCount,
    pairingPolicy,
    scorePreset,
    matchFormat,
    singleGame,
    avoidRecentPartner,
    randomSeed,
    status,
    nextPlayerId,
    nextMatchId,
    nextQueueOrder,
    pairingRound,
    completionOrder,
    defaultRotationMode,
    nextGroupId,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'play_session_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaySessionRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('court_count')) {
      context.handle(
        _courtCountMeta,
        courtCount.isAcceptableOrUnknown(data['court_count']!, _courtCountMeta),
      );
    } else if (isInserting) {
      context.missing(_courtCountMeta);
    }
    if (data.containsKey('pairing_policy')) {
      context.handle(
        _pairingPolicyMeta,
        pairingPolicy.isAcceptableOrUnknown(
          data['pairing_policy']!,
          _pairingPolicyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pairingPolicyMeta);
    }
    if (data.containsKey('score_preset')) {
      context.handle(
        _scorePresetMeta,
        scorePreset.isAcceptableOrUnknown(
          data['score_preset']!,
          _scorePresetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scorePresetMeta);
    }
    if (data.containsKey('match_format')) {
      context.handle(
        _matchFormatMeta,
        matchFormat.isAcceptableOrUnknown(
          data['match_format']!,
          _matchFormatMeta,
        ),
      );
    }
    if (data.containsKey('single_game')) {
      context.handle(
        _singleGameMeta,
        singleGame.isAcceptableOrUnknown(data['single_game']!, _singleGameMeta),
      );
    }
    if (data.containsKey('avoid_recent_partner')) {
      context.handle(
        _avoidRecentPartnerMeta,
        avoidRecentPartner.isAcceptableOrUnknown(
          data['avoid_recent_partner']!,
          _avoidRecentPartnerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_avoidRecentPartnerMeta);
    }
    if (data.containsKey('random_seed')) {
      context.handle(
        _randomSeedMeta,
        randomSeed.isAcceptableOrUnknown(data['random_seed']!, _randomSeedMeta),
      );
    } else if (isInserting) {
      context.missing(_randomSeedMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('next_player_id')) {
      context.handle(
        _nextPlayerIdMeta,
        nextPlayerId.isAcceptableOrUnknown(
          data['next_player_id']!,
          _nextPlayerIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextPlayerIdMeta);
    }
    if (data.containsKey('next_match_id')) {
      context.handle(
        _nextMatchIdMeta,
        nextMatchId.isAcceptableOrUnknown(
          data['next_match_id']!,
          _nextMatchIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextMatchIdMeta);
    }
    if (data.containsKey('next_queue_order')) {
      context.handle(
        _nextQueueOrderMeta,
        nextQueueOrder.isAcceptableOrUnknown(
          data['next_queue_order']!,
          _nextQueueOrderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextQueueOrderMeta);
    }
    if (data.containsKey('pairing_round')) {
      context.handle(
        _pairingRoundMeta,
        pairingRound.isAcceptableOrUnknown(
          data['pairing_round']!,
          _pairingRoundMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pairingRoundMeta);
    }
    if (data.containsKey('completion_order')) {
      context.handle(
        _completionOrderMeta,
        completionOrder.isAcceptableOrUnknown(
          data['completion_order']!,
          _completionOrderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completionOrderMeta);
    }
    if (data.containsKey('default_rotation_mode')) {
      context.handle(
        _defaultRotationModeMeta,
        defaultRotationMode.isAcceptableOrUnknown(
          data['default_rotation_mode']!,
          _defaultRotationModeMeta,
        ),
      );
    }
    if (data.containsKey('next_group_id')) {
      context.handle(
        _nextGroupIdMeta,
        nextGroupId.isAcceptableOrUnknown(
          data['next_group_id']!,
          _nextGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaySessionRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaySessionRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      courtCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}court_count'],
      )!,
      pairingPolicy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pairing_policy'],
      )!,
      scorePreset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}score_preset'],
      )!,
      matchFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_format'],
      ),
      singleGame: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}single_game'],
      ),
      avoidRecentPartner: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}avoid_recent_partner'],
      )!,
      randomSeed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}random_seed'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      nextPlayerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_player_id'],
      )!,
      nextMatchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_match_id'],
      )!,
      nextQueueOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_queue_order'],
      )!,
      pairingRound: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pairing_round'],
      )!,
      completionOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completion_order'],
      )!,
      defaultRotationMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_rotation_mode'],
      )!,
      nextGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_group_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlaySessionRecordsTable createAlias(String alias) {
    return $PlaySessionRecordsTable(attachedDatabase, alias);
  }
}

class PlaySessionRecord extends DataClass
    implements Insertable<PlaySessionRecord> {
  final int id;
  final String title;
  final int courtCount;
  final String pairingPolicy;
  final String scorePreset;
  final String? matchFormat;
  final bool? singleGame;
  final bool avoidRecentPartner;
  final int randomSeed;
  final String status;
  final int nextPlayerId;
  final int nextMatchId;
  final int nextQueueOrder;
  final int pairingRound;
  final int completionOrder;
  final String defaultRotationMode;
  final int nextGroupId;
  final int updatedAt;
  const PlaySessionRecord({
    required this.id,
    required this.title,
    required this.courtCount,
    required this.pairingPolicy,
    required this.scorePreset,
    this.matchFormat,
    this.singleGame,
    required this.avoidRecentPartner,
    required this.randomSeed,
    required this.status,
    required this.nextPlayerId,
    required this.nextMatchId,
    required this.nextQueueOrder,
    required this.pairingRound,
    required this.completionOrder,
    required this.defaultRotationMode,
    required this.nextGroupId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['court_count'] = Variable<int>(courtCount);
    map['pairing_policy'] = Variable<String>(pairingPolicy);
    map['score_preset'] = Variable<String>(scorePreset);
    if (!nullToAbsent || matchFormat != null) {
      map['match_format'] = Variable<String>(matchFormat);
    }
    if (!nullToAbsent || singleGame != null) {
      map['single_game'] = Variable<bool>(singleGame);
    }
    map['avoid_recent_partner'] = Variable<bool>(avoidRecentPartner);
    map['random_seed'] = Variable<int>(randomSeed);
    map['status'] = Variable<String>(status);
    map['next_player_id'] = Variable<int>(nextPlayerId);
    map['next_match_id'] = Variable<int>(nextMatchId);
    map['next_queue_order'] = Variable<int>(nextQueueOrder);
    map['pairing_round'] = Variable<int>(pairingRound);
    map['completion_order'] = Variable<int>(completionOrder);
    map['default_rotation_mode'] = Variable<String>(defaultRotationMode);
    map['next_group_id'] = Variable<int>(nextGroupId);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  PlaySessionRecordsCompanion toCompanion(bool nullToAbsent) {
    return PlaySessionRecordsCompanion(
      id: Value(id),
      title: Value(title),
      courtCount: Value(courtCount),
      pairingPolicy: Value(pairingPolicy),
      scorePreset: Value(scorePreset),
      matchFormat: matchFormat == null && nullToAbsent
          ? const Value.absent()
          : Value(matchFormat),
      singleGame: singleGame == null && nullToAbsent
          ? const Value.absent()
          : Value(singleGame),
      avoidRecentPartner: Value(avoidRecentPartner),
      randomSeed: Value(randomSeed),
      status: Value(status),
      nextPlayerId: Value(nextPlayerId),
      nextMatchId: Value(nextMatchId),
      nextQueueOrder: Value(nextQueueOrder),
      pairingRound: Value(pairingRound),
      completionOrder: Value(completionOrder),
      defaultRotationMode: Value(defaultRotationMode),
      nextGroupId: Value(nextGroupId),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlaySessionRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaySessionRecord(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      courtCount: serializer.fromJson<int>(json['courtCount']),
      pairingPolicy: serializer.fromJson<String>(json['pairingPolicy']),
      scorePreset: serializer.fromJson<String>(json['scorePreset']),
      matchFormat: serializer.fromJson<String?>(json['matchFormat']),
      singleGame: serializer.fromJson<bool?>(json['singleGame']),
      avoidRecentPartner: serializer.fromJson<bool>(json['avoidRecentPartner']),
      randomSeed: serializer.fromJson<int>(json['randomSeed']),
      status: serializer.fromJson<String>(json['status']),
      nextPlayerId: serializer.fromJson<int>(json['nextPlayerId']),
      nextMatchId: serializer.fromJson<int>(json['nextMatchId']),
      nextQueueOrder: serializer.fromJson<int>(json['nextQueueOrder']),
      pairingRound: serializer.fromJson<int>(json['pairingRound']),
      completionOrder: serializer.fromJson<int>(json['completionOrder']),
      defaultRotationMode: serializer.fromJson<String>(
        json['defaultRotationMode'],
      ),
      nextGroupId: serializer.fromJson<int>(json['nextGroupId']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'courtCount': serializer.toJson<int>(courtCount),
      'pairingPolicy': serializer.toJson<String>(pairingPolicy),
      'scorePreset': serializer.toJson<String>(scorePreset),
      'matchFormat': serializer.toJson<String?>(matchFormat),
      'singleGame': serializer.toJson<bool?>(singleGame),
      'avoidRecentPartner': serializer.toJson<bool>(avoidRecentPartner),
      'randomSeed': serializer.toJson<int>(randomSeed),
      'status': serializer.toJson<String>(status),
      'nextPlayerId': serializer.toJson<int>(nextPlayerId),
      'nextMatchId': serializer.toJson<int>(nextMatchId),
      'nextQueueOrder': serializer.toJson<int>(nextQueueOrder),
      'pairingRound': serializer.toJson<int>(pairingRound),
      'completionOrder': serializer.toJson<int>(completionOrder),
      'defaultRotationMode': serializer.toJson<String>(defaultRotationMode),
      'nextGroupId': serializer.toJson<int>(nextGroupId),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  PlaySessionRecord copyWith({
    int? id,
    String? title,
    int? courtCount,
    String? pairingPolicy,
    String? scorePreset,
    Value<String?> matchFormat = const Value.absent(),
    Value<bool?> singleGame = const Value.absent(),
    bool? avoidRecentPartner,
    int? randomSeed,
    String? status,
    int? nextPlayerId,
    int? nextMatchId,
    int? nextQueueOrder,
    int? pairingRound,
    int? completionOrder,
    String? defaultRotationMode,
    int? nextGroupId,
    int? updatedAt,
  }) => PlaySessionRecord(
    id: id ?? this.id,
    title: title ?? this.title,
    courtCount: courtCount ?? this.courtCount,
    pairingPolicy: pairingPolicy ?? this.pairingPolicy,
    scorePreset: scorePreset ?? this.scorePreset,
    matchFormat: matchFormat.present ? matchFormat.value : this.matchFormat,
    singleGame: singleGame.present ? singleGame.value : this.singleGame,
    avoidRecentPartner: avoidRecentPartner ?? this.avoidRecentPartner,
    randomSeed: randomSeed ?? this.randomSeed,
    status: status ?? this.status,
    nextPlayerId: nextPlayerId ?? this.nextPlayerId,
    nextMatchId: nextMatchId ?? this.nextMatchId,
    nextQueueOrder: nextQueueOrder ?? this.nextQueueOrder,
    pairingRound: pairingRound ?? this.pairingRound,
    completionOrder: completionOrder ?? this.completionOrder,
    defaultRotationMode: defaultRotationMode ?? this.defaultRotationMode,
    nextGroupId: nextGroupId ?? this.nextGroupId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PlaySessionRecord copyWithCompanion(PlaySessionRecordsCompanion data) {
    return PlaySessionRecord(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      courtCount: data.courtCount.present
          ? data.courtCount.value
          : this.courtCount,
      pairingPolicy: data.pairingPolicy.present
          ? data.pairingPolicy.value
          : this.pairingPolicy,
      scorePreset: data.scorePreset.present
          ? data.scorePreset.value
          : this.scorePreset,
      matchFormat: data.matchFormat.present
          ? data.matchFormat.value
          : this.matchFormat,
      singleGame: data.singleGame.present
          ? data.singleGame.value
          : this.singleGame,
      avoidRecentPartner: data.avoidRecentPartner.present
          ? data.avoidRecentPartner.value
          : this.avoidRecentPartner,
      randomSeed: data.randomSeed.present
          ? data.randomSeed.value
          : this.randomSeed,
      status: data.status.present ? data.status.value : this.status,
      nextPlayerId: data.nextPlayerId.present
          ? data.nextPlayerId.value
          : this.nextPlayerId,
      nextMatchId: data.nextMatchId.present
          ? data.nextMatchId.value
          : this.nextMatchId,
      nextQueueOrder: data.nextQueueOrder.present
          ? data.nextQueueOrder.value
          : this.nextQueueOrder,
      pairingRound: data.pairingRound.present
          ? data.pairingRound.value
          : this.pairingRound,
      completionOrder: data.completionOrder.present
          ? data.completionOrder.value
          : this.completionOrder,
      defaultRotationMode: data.defaultRotationMode.present
          ? data.defaultRotationMode.value
          : this.defaultRotationMode,
      nextGroupId: data.nextGroupId.present
          ? data.nextGroupId.value
          : this.nextGroupId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaySessionRecord(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('courtCount: $courtCount, ')
          ..write('pairingPolicy: $pairingPolicy, ')
          ..write('scorePreset: $scorePreset, ')
          ..write('matchFormat: $matchFormat, ')
          ..write('singleGame: $singleGame, ')
          ..write('avoidRecentPartner: $avoidRecentPartner, ')
          ..write('randomSeed: $randomSeed, ')
          ..write('status: $status, ')
          ..write('nextPlayerId: $nextPlayerId, ')
          ..write('nextMatchId: $nextMatchId, ')
          ..write('nextQueueOrder: $nextQueueOrder, ')
          ..write('pairingRound: $pairingRound, ')
          ..write('completionOrder: $completionOrder, ')
          ..write('defaultRotationMode: $defaultRotationMode, ')
          ..write('nextGroupId: $nextGroupId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    courtCount,
    pairingPolicy,
    scorePreset,
    matchFormat,
    singleGame,
    avoidRecentPartner,
    randomSeed,
    status,
    nextPlayerId,
    nextMatchId,
    nextQueueOrder,
    pairingRound,
    completionOrder,
    defaultRotationMode,
    nextGroupId,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaySessionRecord &&
          other.id == this.id &&
          other.title == this.title &&
          other.courtCount == this.courtCount &&
          other.pairingPolicy == this.pairingPolicy &&
          other.scorePreset == this.scorePreset &&
          other.matchFormat == this.matchFormat &&
          other.singleGame == this.singleGame &&
          other.avoidRecentPartner == this.avoidRecentPartner &&
          other.randomSeed == this.randomSeed &&
          other.status == this.status &&
          other.nextPlayerId == this.nextPlayerId &&
          other.nextMatchId == this.nextMatchId &&
          other.nextQueueOrder == this.nextQueueOrder &&
          other.pairingRound == this.pairingRound &&
          other.completionOrder == this.completionOrder &&
          other.defaultRotationMode == this.defaultRotationMode &&
          other.nextGroupId == this.nextGroupId &&
          other.updatedAt == this.updatedAt);
}

class PlaySessionRecordsCompanion extends UpdateCompanion<PlaySessionRecord> {
  final Value<int> id;
  final Value<String> title;
  final Value<int> courtCount;
  final Value<String> pairingPolicy;
  final Value<String> scorePreset;
  final Value<String?> matchFormat;
  final Value<bool?> singleGame;
  final Value<bool> avoidRecentPartner;
  final Value<int> randomSeed;
  final Value<String> status;
  final Value<int> nextPlayerId;
  final Value<int> nextMatchId;
  final Value<int> nextQueueOrder;
  final Value<int> pairingRound;
  final Value<int> completionOrder;
  final Value<String> defaultRotationMode;
  final Value<int> nextGroupId;
  final Value<int> updatedAt;
  const PlaySessionRecordsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.courtCount = const Value.absent(),
    this.pairingPolicy = const Value.absent(),
    this.scorePreset = const Value.absent(),
    this.matchFormat = const Value.absent(),
    this.singleGame = const Value.absent(),
    this.avoidRecentPartner = const Value.absent(),
    this.randomSeed = const Value.absent(),
    this.status = const Value.absent(),
    this.nextPlayerId = const Value.absent(),
    this.nextMatchId = const Value.absent(),
    this.nextQueueOrder = const Value.absent(),
    this.pairingRound = const Value.absent(),
    this.completionOrder = const Value.absent(),
    this.defaultRotationMode = const Value.absent(),
    this.nextGroupId = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PlaySessionRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required int courtCount,
    required String pairingPolicy,
    required String scorePreset,
    this.matchFormat = const Value.absent(),
    this.singleGame = const Value.absent(),
    required bool avoidRecentPartner,
    required int randomSeed,
    required String status,
    required int nextPlayerId,
    required int nextMatchId,
    required int nextQueueOrder,
    required int pairingRound,
    required int completionOrder,
    this.defaultRotationMode = const Value.absent(),
    this.nextGroupId = const Value.absent(),
    required int updatedAt,
  }) : title = Value(title),
       courtCount = Value(courtCount),
       pairingPolicy = Value(pairingPolicy),
       scorePreset = Value(scorePreset),
       avoidRecentPartner = Value(avoidRecentPartner),
       randomSeed = Value(randomSeed),
       status = Value(status),
       nextPlayerId = Value(nextPlayerId),
       nextMatchId = Value(nextMatchId),
       nextQueueOrder = Value(nextQueueOrder),
       pairingRound = Value(pairingRound),
       completionOrder = Value(completionOrder),
       updatedAt = Value(updatedAt);
  static Insertable<PlaySessionRecord> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? courtCount,
    Expression<String>? pairingPolicy,
    Expression<String>? scorePreset,
    Expression<String>? matchFormat,
    Expression<bool>? singleGame,
    Expression<bool>? avoidRecentPartner,
    Expression<int>? randomSeed,
    Expression<String>? status,
    Expression<int>? nextPlayerId,
    Expression<int>? nextMatchId,
    Expression<int>? nextQueueOrder,
    Expression<int>? pairingRound,
    Expression<int>? completionOrder,
    Expression<String>? defaultRotationMode,
    Expression<int>? nextGroupId,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (courtCount != null) 'court_count': courtCount,
      if (pairingPolicy != null) 'pairing_policy': pairingPolicy,
      if (scorePreset != null) 'score_preset': scorePreset,
      if (matchFormat != null) 'match_format': matchFormat,
      if (singleGame != null) 'single_game': singleGame,
      if (avoidRecentPartner != null)
        'avoid_recent_partner': avoidRecentPartner,
      if (randomSeed != null) 'random_seed': randomSeed,
      if (status != null) 'status': status,
      if (nextPlayerId != null) 'next_player_id': nextPlayerId,
      if (nextMatchId != null) 'next_match_id': nextMatchId,
      if (nextQueueOrder != null) 'next_queue_order': nextQueueOrder,
      if (pairingRound != null) 'pairing_round': pairingRound,
      if (completionOrder != null) 'completion_order': completionOrder,
      if (defaultRotationMode != null)
        'default_rotation_mode': defaultRotationMode,
      if (nextGroupId != null) 'next_group_id': nextGroupId,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PlaySessionRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<int>? courtCount,
    Value<String>? pairingPolicy,
    Value<String>? scorePreset,
    Value<String?>? matchFormat,
    Value<bool?>? singleGame,
    Value<bool>? avoidRecentPartner,
    Value<int>? randomSeed,
    Value<String>? status,
    Value<int>? nextPlayerId,
    Value<int>? nextMatchId,
    Value<int>? nextQueueOrder,
    Value<int>? pairingRound,
    Value<int>? completionOrder,
    Value<String>? defaultRotationMode,
    Value<int>? nextGroupId,
    Value<int>? updatedAt,
  }) {
    return PlaySessionRecordsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      courtCount: courtCount ?? this.courtCount,
      pairingPolicy: pairingPolicy ?? this.pairingPolicy,
      scorePreset: scorePreset ?? this.scorePreset,
      matchFormat: matchFormat ?? this.matchFormat,
      singleGame: singleGame ?? this.singleGame,
      avoidRecentPartner: avoidRecentPartner ?? this.avoidRecentPartner,
      randomSeed: randomSeed ?? this.randomSeed,
      status: status ?? this.status,
      nextPlayerId: nextPlayerId ?? this.nextPlayerId,
      nextMatchId: nextMatchId ?? this.nextMatchId,
      nextQueueOrder: nextQueueOrder ?? this.nextQueueOrder,
      pairingRound: pairingRound ?? this.pairingRound,
      completionOrder: completionOrder ?? this.completionOrder,
      defaultRotationMode: defaultRotationMode ?? this.defaultRotationMode,
      nextGroupId: nextGroupId ?? this.nextGroupId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (courtCount.present) {
      map['court_count'] = Variable<int>(courtCount.value);
    }
    if (pairingPolicy.present) {
      map['pairing_policy'] = Variable<String>(pairingPolicy.value);
    }
    if (scorePreset.present) {
      map['score_preset'] = Variable<String>(scorePreset.value);
    }
    if (matchFormat.present) {
      map['match_format'] = Variable<String>(matchFormat.value);
    }
    if (singleGame.present) {
      map['single_game'] = Variable<bool>(singleGame.value);
    }
    if (avoidRecentPartner.present) {
      map['avoid_recent_partner'] = Variable<bool>(avoidRecentPartner.value);
    }
    if (randomSeed.present) {
      map['random_seed'] = Variable<int>(randomSeed.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (nextPlayerId.present) {
      map['next_player_id'] = Variable<int>(nextPlayerId.value);
    }
    if (nextMatchId.present) {
      map['next_match_id'] = Variable<int>(nextMatchId.value);
    }
    if (nextQueueOrder.present) {
      map['next_queue_order'] = Variable<int>(nextQueueOrder.value);
    }
    if (pairingRound.present) {
      map['pairing_round'] = Variable<int>(pairingRound.value);
    }
    if (completionOrder.present) {
      map['completion_order'] = Variable<int>(completionOrder.value);
    }
    if (defaultRotationMode.present) {
      map['default_rotation_mode'] = Variable<String>(
        defaultRotationMode.value,
      );
    }
    if (nextGroupId.present) {
      map['next_group_id'] = Variable<int>(nextGroupId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaySessionRecordsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('courtCount: $courtCount, ')
          ..write('pairingPolicy: $pairingPolicy, ')
          ..write('scorePreset: $scorePreset, ')
          ..write('matchFormat: $matchFormat, ')
          ..write('singleGame: $singleGame, ')
          ..write('avoidRecentPartner: $avoidRecentPartner, ')
          ..write('randomSeed: $randomSeed, ')
          ..write('status: $status, ')
          ..write('nextPlayerId: $nextPlayerId, ')
          ..write('nextMatchId: $nextMatchId, ')
          ..write('nextQueueOrder: $nextQueueOrder, ')
          ..write('pairingRound: $pairingRound, ')
          ..write('completionOrder: $completionOrder, ')
          ..write('defaultRotationMode: $defaultRotationMode, ')
          ..write('nextGroupId: $nextGroupId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SessionPlayerRecordsTable extends SessionPlayerRecords
    with TableInfo<$SessionPlayerRecordsTable, SessionPlayerRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionPlayerRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _queueOrderMeta = const VerificationMeta(
    'queueOrder',
  );
  @override
  late final GeneratedColumn<int> queueOrder = GeneratedColumn<int>(
    'queue_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    id,
    name,
    state,
    queueOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_player_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionPlayerRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('queue_order')) {
      context.handle(
        _queueOrderMeta,
        queueOrder.isAcceptableOrUnknown(data['queue_order']!, _queueOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_queueOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, id};
  @override
  SessionPlayerRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionPlayerRecord(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      queueOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}queue_order'],
      )!,
    );
  }

  @override
  $SessionPlayerRecordsTable createAlias(String alias) {
    return $SessionPlayerRecordsTable(attachedDatabase, alias);
  }
}

class SessionPlayerRecord extends DataClass
    implements Insertable<SessionPlayerRecord> {
  final int sessionId;
  final int id;
  final String name;
  final String state;
  final int queueOrder;
  const SessionPlayerRecord({
    required this.sessionId,
    required this.id,
    required this.name,
    required this.state,
    required this.queueOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<int>(sessionId);
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['state'] = Variable<String>(state);
    map['queue_order'] = Variable<int>(queueOrder);
    return map;
  }

  SessionPlayerRecordsCompanion toCompanion(bool nullToAbsent) {
    return SessionPlayerRecordsCompanion(
      sessionId: Value(sessionId),
      id: Value(id),
      name: Value(name),
      state: Value(state),
      queueOrder: Value(queueOrder),
    );
  }

  factory SessionPlayerRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionPlayerRecord(
      sessionId: serializer.fromJson<int>(json['sessionId']),
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      state: serializer.fromJson<String>(json['state']),
      queueOrder: serializer.fromJson<int>(json['queueOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<int>(sessionId),
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'state': serializer.toJson<String>(state),
      'queueOrder': serializer.toJson<int>(queueOrder),
    };
  }

  SessionPlayerRecord copyWith({
    int? sessionId,
    int? id,
    String? name,
    String? state,
    int? queueOrder,
  }) => SessionPlayerRecord(
    sessionId: sessionId ?? this.sessionId,
    id: id ?? this.id,
    name: name ?? this.name,
    state: state ?? this.state,
    queueOrder: queueOrder ?? this.queueOrder,
  );
  SessionPlayerRecord copyWithCompanion(SessionPlayerRecordsCompanion data) {
    return SessionPlayerRecord(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      state: data.state.present ? data.state.value : this.state,
      queueOrder: data.queueOrder.present
          ? data.queueOrder.value
          : this.queueOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionPlayerRecord(')
          ..write('sessionId: $sessionId, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('state: $state, ')
          ..write('queueOrder: $queueOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sessionId, id, name, state, queueOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionPlayerRecord &&
          other.sessionId == this.sessionId &&
          other.id == this.id &&
          other.name == this.name &&
          other.state == this.state &&
          other.queueOrder == this.queueOrder);
}

class SessionPlayerRecordsCompanion
    extends UpdateCompanion<SessionPlayerRecord> {
  final Value<int> sessionId;
  final Value<int> id;
  final Value<String> name;
  final Value<String> state;
  final Value<int> queueOrder;
  final Value<int> rowid;
  const SessionPlayerRecordsCompanion({
    this.sessionId = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.state = const Value.absent(),
    this.queueOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionPlayerRecordsCompanion.insert({
    required int sessionId,
    required int id,
    required String name,
    required String state,
    required int queueOrder,
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       id = Value(id),
       name = Value(name),
       state = Value(state),
       queueOrder = Value(queueOrder);
  static Insertable<SessionPlayerRecord> custom({
    Expression<int>? sessionId,
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? state,
    Expression<int>? queueOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (state != null) 'state': state,
      if (queueOrder != null) 'queue_order': queueOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionPlayerRecordsCompanion copyWith({
    Value<int>? sessionId,
    Value<int>? id,
    Value<String>? name,
    Value<String>? state,
    Value<int>? queueOrder,
    Value<int>? rowid,
  }) {
    return SessionPlayerRecordsCompanion(
      sessionId: sessionId ?? this.sessionId,
      id: id ?? this.id,
      name: name ?? this.name,
      state: state ?? this.state,
      queueOrder: queueOrder ?? this.queueOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (queueOrder.present) {
      map['queue_order'] = Variable<int>(queueOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionPlayerRecordsCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('state: $state, ')
          ..write('queueOrder: $queueOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionGroupRecordsTable extends SessionGroupRecords
    with TableInfo<$SessionGroupRecordsTable, SessionGroupRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionGroupRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstPlayerIdMeta = const VerificationMeta(
    'firstPlayerId',
  );
  @override
  late final GeneratedColumn<int> firstPlayerId = GeneratedColumn<int>(
    'first_player_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _secondPlayerIdMeta = const VerificationMeta(
    'secondPlayerId',
  );
  @override
  late final GeneratedColumn<int> secondPlayerId = GeneratedColumn<int>(
    'second_player_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _queueOrderMeta = const VerificationMeta(
    'queueOrder',
  );
  @override
  late final GeneratedColumn<int> queueOrder = GeneratedColumn<int>(
    'queue_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    id,
    firstPlayerId,
    secondPlayerId,
    state,
    queueOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_group_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionGroupRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('first_player_id')) {
      context.handle(
        _firstPlayerIdMeta,
        firstPlayerId.isAcceptableOrUnknown(
          data['first_player_id']!,
          _firstPlayerIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstPlayerIdMeta);
    }
    if (data.containsKey('second_player_id')) {
      context.handle(
        _secondPlayerIdMeta,
        secondPlayerId.isAcceptableOrUnknown(
          data['second_player_id']!,
          _secondPlayerIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_secondPlayerIdMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('queue_order')) {
      context.handle(
        _queueOrderMeta,
        queueOrder.isAcceptableOrUnknown(data['queue_order']!, _queueOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_queueOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, id};
  @override
  SessionGroupRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionGroupRecord(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      firstPlayerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_player_id'],
      )!,
      secondPlayerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}second_player_id'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      queueOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}queue_order'],
      )!,
    );
  }

  @override
  $SessionGroupRecordsTable createAlias(String alias) {
    return $SessionGroupRecordsTable(attachedDatabase, alias);
  }
}

class SessionGroupRecord extends DataClass
    implements Insertable<SessionGroupRecord> {
  final int sessionId;
  final int id;
  final int firstPlayerId;
  final int secondPlayerId;
  final String state;
  final int queueOrder;
  const SessionGroupRecord({
    required this.sessionId,
    required this.id,
    required this.firstPlayerId,
    required this.secondPlayerId,
    required this.state,
    required this.queueOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<int>(sessionId);
    map['id'] = Variable<int>(id);
    map['first_player_id'] = Variable<int>(firstPlayerId);
    map['second_player_id'] = Variable<int>(secondPlayerId);
    map['state'] = Variable<String>(state);
    map['queue_order'] = Variable<int>(queueOrder);
    return map;
  }

  SessionGroupRecordsCompanion toCompanion(bool nullToAbsent) {
    return SessionGroupRecordsCompanion(
      sessionId: Value(sessionId),
      id: Value(id),
      firstPlayerId: Value(firstPlayerId),
      secondPlayerId: Value(secondPlayerId),
      state: Value(state),
      queueOrder: Value(queueOrder),
    );
  }

  factory SessionGroupRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionGroupRecord(
      sessionId: serializer.fromJson<int>(json['sessionId']),
      id: serializer.fromJson<int>(json['id']),
      firstPlayerId: serializer.fromJson<int>(json['firstPlayerId']),
      secondPlayerId: serializer.fromJson<int>(json['secondPlayerId']),
      state: serializer.fromJson<String>(json['state']),
      queueOrder: serializer.fromJson<int>(json['queueOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<int>(sessionId),
      'id': serializer.toJson<int>(id),
      'firstPlayerId': serializer.toJson<int>(firstPlayerId),
      'secondPlayerId': serializer.toJson<int>(secondPlayerId),
      'state': serializer.toJson<String>(state),
      'queueOrder': serializer.toJson<int>(queueOrder),
    };
  }

  SessionGroupRecord copyWith({
    int? sessionId,
    int? id,
    int? firstPlayerId,
    int? secondPlayerId,
    String? state,
    int? queueOrder,
  }) => SessionGroupRecord(
    sessionId: sessionId ?? this.sessionId,
    id: id ?? this.id,
    firstPlayerId: firstPlayerId ?? this.firstPlayerId,
    secondPlayerId: secondPlayerId ?? this.secondPlayerId,
    state: state ?? this.state,
    queueOrder: queueOrder ?? this.queueOrder,
  );
  SessionGroupRecord copyWithCompanion(SessionGroupRecordsCompanion data) {
    return SessionGroupRecord(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      id: data.id.present ? data.id.value : this.id,
      firstPlayerId: data.firstPlayerId.present
          ? data.firstPlayerId.value
          : this.firstPlayerId,
      secondPlayerId: data.secondPlayerId.present
          ? data.secondPlayerId.value
          : this.secondPlayerId,
      state: data.state.present ? data.state.value : this.state,
      queueOrder: data.queueOrder.present
          ? data.queueOrder.value
          : this.queueOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionGroupRecord(')
          ..write('sessionId: $sessionId, ')
          ..write('id: $id, ')
          ..write('firstPlayerId: $firstPlayerId, ')
          ..write('secondPlayerId: $secondPlayerId, ')
          ..write('state: $state, ')
          ..write('queueOrder: $queueOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    id,
    firstPlayerId,
    secondPlayerId,
    state,
    queueOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionGroupRecord &&
          other.sessionId == this.sessionId &&
          other.id == this.id &&
          other.firstPlayerId == this.firstPlayerId &&
          other.secondPlayerId == this.secondPlayerId &&
          other.state == this.state &&
          other.queueOrder == this.queueOrder);
}

class SessionGroupRecordsCompanion extends UpdateCompanion<SessionGroupRecord> {
  final Value<int> sessionId;
  final Value<int> id;
  final Value<int> firstPlayerId;
  final Value<int> secondPlayerId;
  final Value<String> state;
  final Value<int> queueOrder;
  final Value<int> rowid;
  const SessionGroupRecordsCompanion({
    this.sessionId = const Value.absent(),
    this.id = const Value.absent(),
    this.firstPlayerId = const Value.absent(),
    this.secondPlayerId = const Value.absent(),
    this.state = const Value.absent(),
    this.queueOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionGroupRecordsCompanion.insert({
    required int sessionId,
    required int id,
    required int firstPlayerId,
    required int secondPlayerId,
    required String state,
    required int queueOrder,
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       id = Value(id),
       firstPlayerId = Value(firstPlayerId),
       secondPlayerId = Value(secondPlayerId),
       state = Value(state),
       queueOrder = Value(queueOrder);
  static Insertable<SessionGroupRecord> custom({
    Expression<int>? sessionId,
    Expression<int>? id,
    Expression<int>? firstPlayerId,
    Expression<int>? secondPlayerId,
    Expression<String>? state,
    Expression<int>? queueOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (id != null) 'id': id,
      if (firstPlayerId != null) 'first_player_id': firstPlayerId,
      if (secondPlayerId != null) 'second_player_id': secondPlayerId,
      if (state != null) 'state': state,
      if (queueOrder != null) 'queue_order': queueOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionGroupRecordsCompanion copyWith({
    Value<int>? sessionId,
    Value<int>? id,
    Value<int>? firstPlayerId,
    Value<int>? secondPlayerId,
    Value<String>? state,
    Value<int>? queueOrder,
    Value<int>? rowid,
  }) {
    return SessionGroupRecordsCompanion(
      sessionId: sessionId ?? this.sessionId,
      id: id ?? this.id,
      firstPlayerId: firstPlayerId ?? this.firstPlayerId,
      secondPlayerId: secondPlayerId ?? this.secondPlayerId,
      state: state ?? this.state,
      queueOrder: queueOrder ?? this.queueOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (firstPlayerId.present) {
      map['first_player_id'] = Variable<int>(firstPlayerId.value);
    }
    if (secondPlayerId.present) {
      map['second_player_id'] = Variable<int>(secondPlayerId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (queueOrder.present) {
      map['queue_order'] = Variable<int>(queueOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionGroupRecordsCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('id: $id, ')
          ..write('firstPlayerId: $firstPlayerId, ')
          ..write('secondPlayerId: $secondPlayerId, ')
          ..write('state: $state, ')
          ..write('queueOrder: $queueOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionCourtRecordsTable extends SessionCourtRecords
    with TableInfo<$SessionCourtRecordsTable, SessionCourtRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionCourtRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _matchIdMeta = const VerificationMeta(
    'matchId',
  );
  @override
  late final GeneratedColumn<int> matchId = GeneratedColumn<int>(
    'match_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _stayingGroupIdMeta = const VerificationMeta(
    'stayingGroupId',
  );
  @override
  late final GeneratedColumn<int> stayingGroupId = GeneratedColumn<int>(
    'staying_group_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stayingPlayerIdMeta = const VerificationMeta(
    'stayingPlayerId',
  );
  @override
  late final GeneratedColumn<int> stayingPlayerId = GeneratedColumn<int>(
    'staying_player_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    number,
    state,
    matchId,
    name,
    stayingGroupId,
    stayingPlayerId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_court_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionCourtRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('match_id')) {
      context.handle(
        _matchIdMeta,
        matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('staying_group_id')) {
      context.handle(
        _stayingGroupIdMeta,
        stayingGroupId.isAcceptableOrUnknown(
          data['staying_group_id']!,
          _stayingGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('staying_player_id')) {
      context.handle(
        _stayingPlayerIdMeta,
        stayingPlayerId.isAcceptableOrUnknown(
          data['staying_player_id']!,
          _stayingPlayerIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, number};
  @override
  SessionCourtRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionCourtRecord(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      matchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}match_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      stayingGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}staying_group_id'],
      ),
      stayingPlayerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}staying_player_id'],
      ),
    );
  }

  @override
  $SessionCourtRecordsTable createAlias(String alias) {
    return $SessionCourtRecordsTable(attachedDatabase, alias);
  }
}

class SessionCourtRecord extends DataClass
    implements Insertable<SessionCourtRecord> {
  final int sessionId;
  final int number;
  final String state;
  final int? matchId;
  final String name;
  final int? stayingGroupId;
  final int? stayingPlayerId;
  const SessionCourtRecord({
    required this.sessionId,
    required this.number,
    required this.state,
    this.matchId,
    required this.name,
    this.stayingGroupId,
    this.stayingPlayerId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<int>(sessionId);
    map['number'] = Variable<int>(number);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || matchId != null) {
      map['match_id'] = Variable<int>(matchId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || stayingGroupId != null) {
      map['staying_group_id'] = Variable<int>(stayingGroupId);
    }
    if (!nullToAbsent || stayingPlayerId != null) {
      map['staying_player_id'] = Variable<int>(stayingPlayerId);
    }
    return map;
  }

  SessionCourtRecordsCompanion toCompanion(bool nullToAbsent) {
    return SessionCourtRecordsCompanion(
      sessionId: Value(sessionId),
      number: Value(number),
      state: Value(state),
      matchId: matchId == null && nullToAbsent
          ? const Value.absent()
          : Value(matchId),
      name: Value(name),
      stayingGroupId: stayingGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(stayingGroupId),
      stayingPlayerId: stayingPlayerId == null && nullToAbsent
          ? const Value.absent()
          : Value(stayingPlayerId),
    );
  }

  factory SessionCourtRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionCourtRecord(
      sessionId: serializer.fromJson<int>(json['sessionId']),
      number: serializer.fromJson<int>(json['number']),
      state: serializer.fromJson<String>(json['state']),
      matchId: serializer.fromJson<int?>(json['matchId']),
      name: serializer.fromJson<String>(json['name']),
      stayingGroupId: serializer.fromJson<int?>(json['stayingGroupId']),
      stayingPlayerId: serializer.fromJson<int?>(json['stayingPlayerId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<int>(sessionId),
      'number': serializer.toJson<int>(number),
      'state': serializer.toJson<String>(state),
      'matchId': serializer.toJson<int?>(matchId),
      'name': serializer.toJson<String>(name),
      'stayingGroupId': serializer.toJson<int?>(stayingGroupId),
      'stayingPlayerId': serializer.toJson<int?>(stayingPlayerId),
    };
  }

  SessionCourtRecord copyWith({
    int? sessionId,
    int? number,
    String? state,
    Value<int?> matchId = const Value.absent(),
    String? name,
    Value<int?> stayingGroupId = const Value.absent(),
    Value<int?> stayingPlayerId = const Value.absent(),
  }) => SessionCourtRecord(
    sessionId: sessionId ?? this.sessionId,
    number: number ?? this.number,
    state: state ?? this.state,
    matchId: matchId.present ? matchId.value : this.matchId,
    name: name ?? this.name,
    stayingGroupId: stayingGroupId.present
        ? stayingGroupId.value
        : this.stayingGroupId,
    stayingPlayerId: stayingPlayerId.present
        ? stayingPlayerId.value
        : this.stayingPlayerId,
  );
  SessionCourtRecord copyWithCompanion(SessionCourtRecordsCompanion data) {
    return SessionCourtRecord(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      number: data.number.present ? data.number.value : this.number,
      state: data.state.present ? data.state.value : this.state,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      name: data.name.present ? data.name.value : this.name,
      stayingGroupId: data.stayingGroupId.present
          ? data.stayingGroupId.value
          : this.stayingGroupId,
      stayingPlayerId: data.stayingPlayerId.present
          ? data.stayingPlayerId.value
          : this.stayingPlayerId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionCourtRecord(')
          ..write('sessionId: $sessionId, ')
          ..write('number: $number, ')
          ..write('state: $state, ')
          ..write('matchId: $matchId, ')
          ..write('name: $name, ')
          ..write('stayingGroupId: $stayingGroupId, ')
          ..write('stayingPlayerId: $stayingPlayerId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    number,
    state,
    matchId,
    name,
    stayingGroupId,
    stayingPlayerId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionCourtRecord &&
          other.sessionId == this.sessionId &&
          other.number == this.number &&
          other.state == this.state &&
          other.matchId == this.matchId &&
          other.name == this.name &&
          other.stayingGroupId == this.stayingGroupId &&
          other.stayingPlayerId == this.stayingPlayerId);
}

class SessionCourtRecordsCompanion extends UpdateCompanion<SessionCourtRecord> {
  final Value<int> sessionId;
  final Value<int> number;
  final Value<String> state;
  final Value<int?> matchId;
  final Value<String> name;
  final Value<int?> stayingGroupId;
  final Value<int?> stayingPlayerId;
  final Value<int> rowid;
  const SessionCourtRecordsCompanion({
    this.sessionId = const Value.absent(),
    this.number = const Value.absent(),
    this.state = const Value.absent(),
    this.matchId = const Value.absent(),
    this.name = const Value.absent(),
    this.stayingGroupId = const Value.absent(),
    this.stayingPlayerId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionCourtRecordsCompanion.insert({
    required int sessionId,
    required int number,
    required String state,
    this.matchId = const Value.absent(),
    this.name = const Value.absent(),
    this.stayingGroupId = const Value.absent(),
    this.stayingPlayerId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       number = Value(number),
       state = Value(state);
  static Insertable<SessionCourtRecord> custom({
    Expression<int>? sessionId,
    Expression<int>? number,
    Expression<String>? state,
    Expression<int>? matchId,
    Expression<String>? name,
    Expression<int>? stayingGroupId,
    Expression<int>? stayingPlayerId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (number != null) 'number': number,
      if (state != null) 'state': state,
      if (matchId != null) 'match_id': matchId,
      if (name != null) 'name': name,
      if (stayingGroupId != null) 'staying_group_id': stayingGroupId,
      if (stayingPlayerId != null) 'staying_player_id': stayingPlayerId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionCourtRecordsCompanion copyWith({
    Value<int>? sessionId,
    Value<int>? number,
    Value<String>? state,
    Value<int?>? matchId,
    Value<String>? name,
    Value<int?>? stayingGroupId,
    Value<int?>? stayingPlayerId,
    Value<int>? rowid,
  }) {
    return SessionCourtRecordsCompanion(
      sessionId: sessionId ?? this.sessionId,
      number: number ?? this.number,
      state: state ?? this.state,
      matchId: matchId ?? this.matchId,
      name: name ?? this.name,
      stayingGroupId: stayingGroupId ?? this.stayingGroupId,
      stayingPlayerId: stayingPlayerId ?? this.stayingPlayerId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (matchId.present) {
      map['match_id'] = Variable<int>(matchId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (stayingGroupId.present) {
      map['staying_group_id'] = Variable<int>(stayingGroupId.value);
    }
    if (stayingPlayerId.present) {
      map['staying_player_id'] = Variable<int>(stayingPlayerId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionCourtRecordsCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('number: $number, ')
          ..write('state: $state, ')
          ..write('matchId: $matchId, ')
          ..write('name: $name, ')
          ..write('stayingGroupId: $stayingGroupId, ')
          ..write('stayingPlayerId: $stayingPlayerId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionMatchRecordsTable extends SessionMatchRecords
    with TableInfo<$SessionMatchRecordsTable, SessionMatchRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionMatchRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courtNumberMeta = const VerificationMeta(
    'courtNumber',
  );
  @override
  late final GeneratedColumn<int> courtNumber = GeneratedColumn<int>(
    'court_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teamAFirstMeta = const VerificationMeta(
    'teamAFirst',
  );
  @override
  late final GeneratedColumn<int> teamAFirst = GeneratedColumn<int>(
    'team_a_first',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teamASecondMeta = const VerificationMeta(
    'teamASecond',
  );
  @override
  late final GeneratedColumn<int> teamASecond = GeneratedColumn<int>(
    'team_a_second',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teamBFirstMeta = const VerificationMeta(
    'teamBFirst',
  );
  @override
  late final GeneratedColumn<int> teamBFirst = GeneratedColumn<int>(
    'team_b_first',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teamBSecondMeta = const VerificationMeta(
    'teamBSecond',
  );
  @override
  late final GeneratedColumn<int> teamBSecond = GeneratedColumn<int>(
    'team_b_second',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relaxedMeta = const VerificationMeta(
    'relaxed',
  );
  @override
  late final GeneratedColumn<bool> relaxed = GeneratedColumn<bool>(
    'relaxed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("relaxed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _resultModeMeta = const VerificationMeta(
    'resultMode',
  );
  @override
  late final GeneratedColumn<String> resultMode = GeneratedColumn<String>(
    'result_mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _winnerMeta = const VerificationMeta('winner');
  @override
  late final GeneratedColumn<String> winner = GeneratedColumn<String>(
    'winner',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedOrderMeta = const VerificationMeta(
    'completedOrder',
  );
  @override
  late final GeneratedColumn<int> completedOrder = GeneratedColumn<int>(
    'completed_order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupAIdMeta = const VerificationMeta(
    'groupAId',
  );
  @override
  late final GeneratedColumn<int> groupAId = GeneratedColumn<int>(
    'group_a_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupBIdMeta = const VerificationMeta(
    'groupBId',
  );
  @override
  late final GeneratedColumn<int> groupBId = GeneratedColumn<int>(
    'group_b_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rotationModeMeta = const VerificationMeta(
    'rotationMode',
  );
  @override
  late final GeneratedColumn<String> rotationMode = GeneratedColumn<String>(
    'rotation_mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    id,
    courtNumber,
    teamAFirst,
    teamASecond,
    teamBFirst,
    teamBSecond,
    state,
    relaxed,
    resultMode,
    winner,
    completedOrder,
    groupAId,
    groupBId,
    rotationMode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_match_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionMatchRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('court_number')) {
      context.handle(
        _courtNumberMeta,
        courtNumber.isAcceptableOrUnknown(
          data['court_number']!,
          _courtNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_courtNumberMeta);
    }
    if (data.containsKey('team_a_first')) {
      context.handle(
        _teamAFirstMeta,
        teamAFirst.isAcceptableOrUnknown(
          data['team_a_first']!,
          _teamAFirstMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_teamAFirstMeta);
    }
    if (data.containsKey('team_a_second')) {
      context.handle(
        _teamASecondMeta,
        teamASecond.isAcceptableOrUnknown(
          data['team_a_second']!,
          _teamASecondMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_teamASecondMeta);
    }
    if (data.containsKey('team_b_first')) {
      context.handle(
        _teamBFirstMeta,
        teamBFirst.isAcceptableOrUnknown(
          data['team_b_first']!,
          _teamBFirstMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_teamBFirstMeta);
    }
    if (data.containsKey('team_b_second')) {
      context.handle(
        _teamBSecondMeta,
        teamBSecond.isAcceptableOrUnknown(
          data['team_b_second']!,
          _teamBSecondMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_teamBSecondMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('relaxed')) {
      context.handle(
        _relaxedMeta,
        relaxed.isAcceptableOrUnknown(data['relaxed']!, _relaxedMeta),
      );
    } else if (isInserting) {
      context.missing(_relaxedMeta);
    }
    if (data.containsKey('result_mode')) {
      context.handle(
        _resultModeMeta,
        resultMode.isAcceptableOrUnknown(data['result_mode']!, _resultModeMeta),
      );
    }
    if (data.containsKey('winner')) {
      context.handle(
        _winnerMeta,
        winner.isAcceptableOrUnknown(data['winner']!, _winnerMeta),
      );
    }
    if (data.containsKey('completed_order')) {
      context.handle(
        _completedOrderMeta,
        completedOrder.isAcceptableOrUnknown(
          data['completed_order']!,
          _completedOrderMeta,
        ),
      );
    }
    if (data.containsKey('group_a_id')) {
      context.handle(
        _groupAIdMeta,
        groupAId.isAcceptableOrUnknown(data['group_a_id']!, _groupAIdMeta),
      );
    }
    if (data.containsKey('group_b_id')) {
      context.handle(
        _groupBIdMeta,
        groupBId.isAcceptableOrUnknown(data['group_b_id']!, _groupBIdMeta),
      );
    }
    if (data.containsKey('rotation_mode')) {
      context.handle(
        _rotationModeMeta,
        rotationMode.isAcceptableOrUnknown(
          data['rotation_mode']!,
          _rotationModeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, id};
  @override
  SessionMatchRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionMatchRecord(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      courtNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}court_number'],
      )!,
      teamAFirst: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}team_a_first'],
      )!,
      teamASecond: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}team_a_second'],
      )!,
      teamBFirst: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}team_b_first'],
      )!,
      teamBSecond: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}team_b_second'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      relaxed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}relaxed'],
      )!,
      resultMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_mode'],
      ),
      winner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}winner'],
      ),
      completedOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_order'],
      ),
      groupAId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_a_id'],
      ),
      groupBId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_b_id'],
      ),
      rotationMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rotation_mode'],
      ),
    );
  }

  @override
  $SessionMatchRecordsTable createAlias(String alias) {
    return $SessionMatchRecordsTable(attachedDatabase, alias);
  }
}

class SessionMatchRecord extends DataClass
    implements Insertable<SessionMatchRecord> {
  final int sessionId;
  final int id;
  final int courtNumber;
  final int teamAFirst;
  final int teamASecond;
  final int teamBFirst;
  final int teamBSecond;
  final String state;
  final bool relaxed;
  final String? resultMode;
  final String? winner;
  final int? completedOrder;
  final int? groupAId;
  final int? groupBId;
  final String? rotationMode;
  const SessionMatchRecord({
    required this.sessionId,
    required this.id,
    required this.courtNumber,
    required this.teamAFirst,
    required this.teamASecond,
    required this.teamBFirst,
    required this.teamBSecond,
    required this.state,
    required this.relaxed,
    this.resultMode,
    this.winner,
    this.completedOrder,
    this.groupAId,
    this.groupBId,
    this.rotationMode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<int>(sessionId);
    map['id'] = Variable<int>(id);
    map['court_number'] = Variable<int>(courtNumber);
    map['team_a_first'] = Variable<int>(teamAFirst);
    map['team_a_second'] = Variable<int>(teamASecond);
    map['team_b_first'] = Variable<int>(teamBFirst);
    map['team_b_second'] = Variable<int>(teamBSecond);
    map['state'] = Variable<String>(state);
    map['relaxed'] = Variable<bool>(relaxed);
    if (!nullToAbsent || resultMode != null) {
      map['result_mode'] = Variable<String>(resultMode);
    }
    if (!nullToAbsent || winner != null) {
      map['winner'] = Variable<String>(winner);
    }
    if (!nullToAbsent || completedOrder != null) {
      map['completed_order'] = Variable<int>(completedOrder);
    }
    if (!nullToAbsent || groupAId != null) {
      map['group_a_id'] = Variable<int>(groupAId);
    }
    if (!nullToAbsent || groupBId != null) {
      map['group_b_id'] = Variable<int>(groupBId);
    }
    if (!nullToAbsent || rotationMode != null) {
      map['rotation_mode'] = Variable<String>(rotationMode);
    }
    return map;
  }

  SessionMatchRecordsCompanion toCompanion(bool nullToAbsent) {
    return SessionMatchRecordsCompanion(
      sessionId: Value(sessionId),
      id: Value(id),
      courtNumber: Value(courtNumber),
      teamAFirst: Value(teamAFirst),
      teamASecond: Value(teamASecond),
      teamBFirst: Value(teamBFirst),
      teamBSecond: Value(teamBSecond),
      state: Value(state),
      relaxed: Value(relaxed),
      resultMode: resultMode == null && nullToAbsent
          ? const Value.absent()
          : Value(resultMode),
      winner: winner == null && nullToAbsent
          ? const Value.absent()
          : Value(winner),
      completedOrder: completedOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(completedOrder),
      groupAId: groupAId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupAId),
      groupBId: groupBId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupBId),
      rotationMode: rotationMode == null && nullToAbsent
          ? const Value.absent()
          : Value(rotationMode),
    );
  }

  factory SessionMatchRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionMatchRecord(
      sessionId: serializer.fromJson<int>(json['sessionId']),
      id: serializer.fromJson<int>(json['id']),
      courtNumber: serializer.fromJson<int>(json['courtNumber']),
      teamAFirst: serializer.fromJson<int>(json['teamAFirst']),
      teamASecond: serializer.fromJson<int>(json['teamASecond']),
      teamBFirst: serializer.fromJson<int>(json['teamBFirst']),
      teamBSecond: serializer.fromJson<int>(json['teamBSecond']),
      state: serializer.fromJson<String>(json['state']),
      relaxed: serializer.fromJson<bool>(json['relaxed']),
      resultMode: serializer.fromJson<String?>(json['resultMode']),
      winner: serializer.fromJson<String?>(json['winner']),
      completedOrder: serializer.fromJson<int?>(json['completedOrder']),
      groupAId: serializer.fromJson<int?>(json['groupAId']),
      groupBId: serializer.fromJson<int?>(json['groupBId']),
      rotationMode: serializer.fromJson<String?>(json['rotationMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<int>(sessionId),
      'id': serializer.toJson<int>(id),
      'courtNumber': serializer.toJson<int>(courtNumber),
      'teamAFirst': serializer.toJson<int>(teamAFirst),
      'teamASecond': serializer.toJson<int>(teamASecond),
      'teamBFirst': serializer.toJson<int>(teamBFirst),
      'teamBSecond': serializer.toJson<int>(teamBSecond),
      'state': serializer.toJson<String>(state),
      'relaxed': serializer.toJson<bool>(relaxed),
      'resultMode': serializer.toJson<String?>(resultMode),
      'winner': serializer.toJson<String?>(winner),
      'completedOrder': serializer.toJson<int?>(completedOrder),
      'groupAId': serializer.toJson<int?>(groupAId),
      'groupBId': serializer.toJson<int?>(groupBId),
      'rotationMode': serializer.toJson<String?>(rotationMode),
    };
  }

  SessionMatchRecord copyWith({
    int? sessionId,
    int? id,
    int? courtNumber,
    int? teamAFirst,
    int? teamASecond,
    int? teamBFirst,
    int? teamBSecond,
    String? state,
    bool? relaxed,
    Value<String?> resultMode = const Value.absent(),
    Value<String?> winner = const Value.absent(),
    Value<int?> completedOrder = const Value.absent(),
    Value<int?> groupAId = const Value.absent(),
    Value<int?> groupBId = const Value.absent(),
    Value<String?> rotationMode = const Value.absent(),
  }) => SessionMatchRecord(
    sessionId: sessionId ?? this.sessionId,
    id: id ?? this.id,
    courtNumber: courtNumber ?? this.courtNumber,
    teamAFirst: teamAFirst ?? this.teamAFirst,
    teamASecond: teamASecond ?? this.teamASecond,
    teamBFirst: teamBFirst ?? this.teamBFirst,
    teamBSecond: teamBSecond ?? this.teamBSecond,
    state: state ?? this.state,
    relaxed: relaxed ?? this.relaxed,
    resultMode: resultMode.present ? resultMode.value : this.resultMode,
    winner: winner.present ? winner.value : this.winner,
    completedOrder: completedOrder.present
        ? completedOrder.value
        : this.completedOrder,
    groupAId: groupAId.present ? groupAId.value : this.groupAId,
    groupBId: groupBId.present ? groupBId.value : this.groupBId,
    rotationMode: rotationMode.present ? rotationMode.value : this.rotationMode,
  );
  SessionMatchRecord copyWithCompanion(SessionMatchRecordsCompanion data) {
    return SessionMatchRecord(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      id: data.id.present ? data.id.value : this.id,
      courtNumber: data.courtNumber.present
          ? data.courtNumber.value
          : this.courtNumber,
      teamAFirst: data.teamAFirst.present
          ? data.teamAFirst.value
          : this.teamAFirst,
      teamASecond: data.teamASecond.present
          ? data.teamASecond.value
          : this.teamASecond,
      teamBFirst: data.teamBFirst.present
          ? data.teamBFirst.value
          : this.teamBFirst,
      teamBSecond: data.teamBSecond.present
          ? data.teamBSecond.value
          : this.teamBSecond,
      state: data.state.present ? data.state.value : this.state,
      relaxed: data.relaxed.present ? data.relaxed.value : this.relaxed,
      resultMode: data.resultMode.present
          ? data.resultMode.value
          : this.resultMode,
      winner: data.winner.present ? data.winner.value : this.winner,
      completedOrder: data.completedOrder.present
          ? data.completedOrder.value
          : this.completedOrder,
      groupAId: data.groupAId.present ? data.groupAId.value : this.groupAId,
      groupBId: data.groupBId.present ? data.groupBId.value : this.groupBId,
      rotationMode: data.rotationMode.present
          ? data.rotationMode.value
          : this.rotationMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionMatchRecord(')
          ..write('sessionId: $sessionId, ')
          ..write('id: $id, ')
          ..write('courtNumber: $courtNumber, ')
          ..write('teamAFirst: $teamAFirst, ')
          ..write('teamASecond: $teamASecond, ')
          ..write('teamBFirst: $teamBFirst, ')
          ..write('teamBSecond: $teamBSecond, ')
          ..write('state: $state, ')
          ..write('relaxed: $relaxed, ')
          ..write('resultMode: $resultMode, ')
          ..write('winner: $winner, ')
          ..write('completedOrder: $completedOrder, ')
          ..write('groupAId: $groupAId, ')
          ..write('groupBId: $groupBId, ')
          ..write('rotationMode: $rotationMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    id,
    courtNumber,
    teamAFirst,
    teamASecond,
    teamBFirst,
    teamBSecond,
    state,
    relaxed,
    resultMode,
    winner,
    completedOrder,
    groupAId,
    groupBId,
    rotationMode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionMatchRecord &&
          other.sessionId == this.sessionId &&
          other.id == this.id &&
          other.courtNumber == this.courtNumber &&
          other.teamAFirst == this.teamAFirst &&
          other.teamASecond == this.teamASecond &&
          other.teamBFirst == this.teamBFirst &&
          other.teamBSecond == this.teamBSecond &&
          other.state == this.state &&
          other.relaxed == this.relaxed &&
          other.resultMode == this.resultMode &&
          other.winner == this.winner &&
          other.completedOrder == this.completedOrder &&
          other.groupAId == this.groupAId &&
          other.groupBId == this.groupBId &&
          other.rotationMode == this.rotationMode);
}

class SessionMatchRecordsCompanion extends UpdateCompanion<SessionMatchRecord> {
  final Value<int> sessionId;
  final Value<int> id;
  final Value<int> courtNumber;
  final Value<int> teamAFirst;
  final Value<int> teamASecond;
  final Value<int> teamBFirst;
  final Value<int> teamBSecond;
  final Value<String> state;
  final Value<bool> relaxed;
  final Value<String?> resultMode;
  final Value<String?> winner;
  final Value<int?> completedOrder;
  final Value<int?> groupAId;
  final Value<int?> groupBId;
  final Value<String?> rotationMode;
  final Value<int> rowid;
  const SessionMatchRecordsCompanion({
    this.sessionId = const Value.absent(),
    this.id = const Value.absent(),
    this.courtNumber = const Value.absent(),
    this.teamAFirst = const Value.absent(),
    this.teamASecond = const Value.absent(),
    this.teamBFirst = const Value.absent(),
    this.teamBSecond = const Value.absent(),
    this.state = const Value.absent(),
    this.relaxed = const Value.absent(),
    this.resultMode = const Value.absent(),
    this.winner = const Value.absent(),
    this.completedOrder = const Value.absent(),
    this.groupAId = const Value.absent(),
    this.groupBId = const Value.absent(),
    this.rotationMode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionMatchRecordsCompanion.insert({
    required int sessionId,
    required int id,
    required int courtNumber,
    required int teamAFirst,
    required int teamASecond,
    required int teamBFirst,
    required int teamBSecond,
    required String state,
    required bool relaxed,
    this.resultMode = const Value.absent(),
    this.winner = const Value.absent(),
    this.completedOrder = const Value.absent(),
    this.groupAId = const Value.absent(),
    this.groupBId = const Value.absent(),
    this.rotationMode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       id = Value(id),
       courtNumber = Value(courtNumber),
       teamAFirst = Value(teamAFirst),
       teamASecond = Value(teamASecond),
       teamBFirst = Value(teamBFirst),
       teamBSecond = Value(teamBSecond),
       state = Value(state),
       relaxed = Value(relaxed);
  static Insertable<SessionMatchRecord> custom({
    Expression<int>? sessionId,
    Expression<int>? id,
    Expression<int>? courtNumber,
    Expression<int>? teamAFirst,
    Expression<int>? teamASecond,
    Expression<int>? teamBFirst,
    Expression<int>? teamBSecond,
    Expression<String>? state,
    Expression<bool>? relaxed,
    Expression<String>? resultMode,
    Expression<String>? winner,
    Expression<int>? completedOrder,
    Expression<int>? groupAId,
    Expression<int>? groupBId,
    Expression<String>? rotationMode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (id != null) 'id': id,
      if (courtNumber != null) 'court_number': courtNumber,
      if (teamAFirst != null) 'team_a_first': teamAFirst,
      if (teamASecond != null) 'team_a_second': teamASecond,
      if (teamBFirst != null) 'team_b_first': teamBFirst,
      if (teamBSecond != null) 'team_b_second': teamBSecond,
      if (state != null) 'state': state,
      if (relaxed != null) 'relaxed': relaxed,
      if (resultMode != null) 'result_mode': resultMode,
      if (winner != null) 'winner': winner,
      if (completedOrder != null) 'completed_order': completedOrder,
      if (groupAId != null) 'group_a_id': groupAId,
      if (groupBId != null) 'group_b_id': groupBId,
      if (rotationMode != null) 'rotation_mode': rotationMode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionMatchRecordsCompanion copyWith({
    Value<int>? sessionId,
    Value<int>? id,
    Value<int>? courtNumber,
    Value<int>? teamAFirst,
    Value<int>? teamASecond,
    Value<int>? teamBFirst,
    Value<int>? teamBSecond,
    Value<String>? state,
    Value<bool>? relaxed,
    Value<String?>? resultMode,
    Value<String?>? winner,
    Value<int?>? completedOrder,
    Value<int?>? groupAId,
    Value<int?>? groupBId,
    Value<String?>? rotationMode,
    Value<int>? rowid,
  }) {
    return SessionMatchRecordsCompanion(
      sessionId: sessionId ?? this.sessionId,
      id: id ?? this.id,
      courtNumber: courtNumber ?? this.courtNumber,
      teamAFirst: teamAFirst ?? this.teamAFirst,
      teamASecond: teamASecond ?? this.teamASecond,
      teamBFirst: teamBFirst ?? this.teamBFirst,
      teamBSecond: teamBSecond ?? this.teamBSecond,
      state: state ?? this.state,
      relaxed: relaxed ?? this.relaxed,
      resultMode: resultMode ?? this.resultMode,
      winner: winner ?? this.winner,
      completedOrder: completedOrder ?? this.completedOrder,
      groupAId: groupAId ?? this.groupAId,
      groupBId: groupBId ?? this.groupBId,
      rotationMode: rotationMode ?? this.rotationMode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (courtNumber.present) {
      map['court_number'] = Variable<int>(courtNumber.value);
    }
    if (teamAFirst.present) {
      map['team_a_first'] = Variable<int>(teamAFirst.value);
    }
    if (teamASecond.present) {
      map['team_a_second'] = Variable<int>(teamASecond.value);
    }
    if (teamBFirst.present) {
      map['team_b_first'] = Variable<int>(teamBFirst.value);
    }
    if (teamBSecond.present) {
      map['team_b_second'] = Variable<int>(teamBSecond.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (relaxed.present) {
      map['relaxed'] = Variable<bool>(relaxed.value);
    }
    if (resultMode.present) {
      map['result_mode'] = Variable<String>(resultMode.value);
    }
    if (winner.present) {
      map['winner'] = Variable<String>(winner.value);
    }
    if (completedOrder.present) {
      map['completed_order'] = Variable<int>(completedOrder.value);
    }
    if (groupAId.present) {
      map['group_a_id'] = Variable<int>(groupAId.value);
    }
    if (groupBId.present) {
      map['group_b_id'] = Variable<int>(groupBId.value);
    }
    if (rotationMode.present) {
      map['rotation_mode'] = Variable<String>(rotationMode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionMatchRecordsCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('id: $id, ')
          ..write('courtNumber: $courtNumber, ')
          ..write('teamAFirst: $teamAFirst, ')
          ..write('teamASecond: $teamASecond, ')
          ..write('teamBFirst: $teamBFirst, ')
          ..write('teamBSecond: $teamBSecond, ')
          ..write('state: $state, ')
          ..write('relaxed: $relaxed, ')
          ..write('resultMode: $resultMode, ')
          ..write('winner: $winner, ')
          ..write('completedOrder: $completedOrder, ')
          ..write('groupAId: $groupAId, ')
          ..write('groupBId: $groupBId, ')
          ..write('rotationMode: $rotationMode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MatchGameRecordsTable extends MatchGameRecords
    with TableInfo<$MatchGameRecordsTable, MatchGameRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatchGameRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _matchIdMeta = const VerificationMeta(
    'matchId',
  );
  @override
  late final GeneratedColumn<int> matchId = GeneratedColumn<int>(
    'match_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameIndexMeta = const VerificationMeta(
    'gameIndex',
  );
  @override
  late final GeneratedColumn<int> gameIndex = GeneratedColumn<int>(
    'game_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sideAMeta = const VerificationMeta('sideA');
  @override
  late final GeneratedColumn<int> sideA = GeneratedColumn<int>(
    'side_a',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sideBMeta = const VerificationMeta('sideB');
  @override
  late final GeneratedColumn<int> sideB = GeneratedColumn<int>(
    'side_b',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    matchId,
    gameIndex,
    sideA,
    sideB,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'match_game_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<MatchGameRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('match_id')) {
      context.handle(
        _matchIdMeta,
        matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('game_index')) {
      context.handle(
        _gameIndexMeta,
        gameIndex.isAcceptableOrUnknown(data['game_index']!, _gameIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIndexMeta);
    }
    if (data.containsKey('side_a')) {
      context.handle(
        _sideAMeta,
        sideA.isAcceptableOrUnknown(data['side_a']!, _sideAMeta),
      );
    } else if (isInserting) {
      context.missing(_sideAMeta);
    }
    if (data.containsKey('side_b')) {
      context.handle(
        _sideBMeta,
        sideB.isAcceptableOrUnknown(data['side_b']!, _sideBMeta),
      );
    } else if (isInserting) {
      context.missing(_sideBMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, matchId, gameIndex};
  @override
  MatchGameRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MatchGameRecord(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      matchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}match_id'],
      )!,
      gameIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_index'],
      )!,
      sideA: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}side_a'],
      )!,
      sideB: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}side_b'],
      )!,
    );
  }

  @override
  $MatchGameRecordsTable createAlias(String alias) {
    return $MatchGameRecordsTable(attachedDatabase, alias);
  }
}

class MatchGameRecord extends DataClass implements Insertable<MatchGameRecord> {
  final int sessionId;
  final int matchId;
  final int gameIndex;
  final int sideA;
  final int sideB;
  const MatchGameRecord({
    required this.sessionId,
    required this.matchId,
    required this.gameIndex,
    required this.sideA,
    required this.sideB,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<int>(sessionId);
    map['match_id'] = Variable<int>(matchId);
    map['game_index'] = Variable<int>(gameIndex);
    map['side_a'] = Variable<int>(sideA);
    map['side_b'] = Variable<int>(sideB);
    return map;
  }

  MatchGameRecordsCompanion toCompanion(bool nullToAbsent) {
    return MatchGameRecordsCompanion(
      sessionId: Value(sessionId),
      matchId: Value(matchId),
      gameIndex: Value(gameIndex),
      sideA: Value(sideA),
      sideB: Value(sideB),
    );
  }

  factory MatchGameRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MatchGameRecord(
      sessionId: serializer.fromJson<int>(json['sessionId']),
      matchId: serializer.fromJson<int>(json['matchId']),
      gameIndex: serializer.fromJson<int>(json['gameIndex']),
      sideA: serializer.fromJson<int>(json['sideA']),
      sideB: serializer.fromJson<int>(json['sideB']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<int>(sessionId),
      'matchId': serializer.toJson<int>(matchId),
      'gameIndex': serializer.toJson<int>(gameIndex),
      'sideA': serializer.toJson<int>(sideA),
      'sideB': serializer.toJson<int>(sideB),
    };
  }

  MatchGameRecord copyWith({
    int? sessionId,
    int? matchId,
    int? gameIndex,
    int? sideA,
    int? sideB,
  }) => MatchGameRecord(
    sessionId: sessionId ?? this.sessionId,
    matchId: matchId ?? this.matchId,
    gameIndex: gameIndex ?? this.gameIndex,
    sideA: sideA ?? this.sideA,
    sideB: sideB ?? this.sideB,
  );
  MatchGameRecord copyWithCompanion(MatchGameRecordsCompanion data) {
    return MatchGameRecord(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      gameIndex: data.gameIndex.present ? data.gameIndex.value : this.gameIndex,
      sideA: data.sideA.present ? data.sideA.value : this.sideA,
      sideB: data.sideB.present ? data.sideB.value : this.sideB,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MatchGameRecord(')
          ..write('sessionId: $sessionId, ')
          ..write('matchId: $matchId, ')
          ..write('gameIndex: $gameIndex, ')
          ..write('sideA: $sideA, ')
          ..write('sideB: $sideB')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sessionId, matchId, gameIndex, sideA, sideB);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MatchGameRecord &&
          other.sessionId == this.sessionId &&
          other.matchId == this.matchId &&
          other.gameIndex == this.gameIndex &&
          other.sideA == this.sideA &&
          other.sideB == this.sideB);
}

class MatchGameRecordsCompanion extends UpdateCompanion<MatchGameRecord> {
  final Value<int> sessionId;
  final Value<int> matchId;
  final Value<int> gameIndex;
  final Value<int> sideA;
  final Value<int> sideB;
  final Value<int> rowid;
  const MatchGameRecordsCompanion({
    this.sessionId = const Value.absent(),
    this.matchId = const Value.absent(),
    this.gameIndex = const Value.absent(),
    this.sideA = const Value.absent(),
    this.sideB = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MatchGameRecordsCompanion.insert({
    required int sessionId,
    required int matchId,
    required int gameIndex,
    required int sideA,
    required int sideB,
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       matchId = Value(matchId),
       gameIndex = Value(gameIndex),
       sideA = Value(sideA),
       sideB = Value(sideB);
  static Insertable<MatchGameRecord> custom({
    Expression<int>? sessionId,
    Expression<int>? matchId,
    Expression<int>? gameIndex,
    Expression<int>? sideA,
    Expression<int>? sideB,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (matchId != null) 'match_id': matchId,
      if (gameIndex != null) 'game_index': gameIndex,
      if (sideA != null) 'side_a': sideA,
      if (sideB != null) 'side_b': sideB,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MatchGameRecordsCompanion copyWith({
    Value<int>? sessionId,
    Value<int>? matchId,
    Value<int>? gameIndex,
    Value<int>? sideA,
    Value<int>? sideB,
    Value<int>? rowid,
  }) {
    return MatchGameRecordsCompanion(
      sessionId: sessionId ?? this.sessionId,
      matchId: matchId ?? this.matchId,
      gameIndex: gameIndex ?? this.gameIndex,
      sideA: sideA ?? this.sideA,
      sideB: sideB ?? this.sideB,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (matchId.present) {
      map['match_id'] = Variable<int>(matchId.value);
    }
    if (gameIndex.present) {
      map['game_index'] = Variable<int>(gameIndex.value);
    }
    if (sideA.present) {
      map['side_a'] = Variable<int>(sideA.value);
    }
    if (sideB.present) {
      map['side_b'] = Variable<int>(sideB.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatchGameRecordsCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('matchId: $matchId, ')
          ..write('gameIndex: $gameIndex, ')
          ..write('sideA: $sideA, ')
          ..write('sideB: $sideB, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$FdRallyPairDatabase extends GeneratedDatabase {
  _$FdRallyPairDatabase(QueryExecutor e) : super(e);
  late final $PlaySessionRecordsTable playSessionRecords =
      $PlaySessionRecordsTable(this);
  late final $SessionPlayerRecordsTable sessionPlayerRecords =
      $SessionPlayerRecordsTable(this);
  late final $SessionGroupRecordsTable sessionGroupRecords =
      $SessionGroupRecordsTable(this);
  late final $SessionCourtRecordsTable sessionCourtRecords =
      $SessionCourtRecordsTable(this);
  late final $SessionMatchRecordsTable sessionMatchRecords =
      $SessionMatchRecordsTable(this);
  late final $MatchGameRecordsTable matchGameRecords = $MatchGameRecordsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    playSessionRecords,
    sessionPlayerRecords,
    sessionGroupRecords,
    sessionCourtRecords,
    sessionMatchRecords,
    matchGameRecords,
  ];
}
