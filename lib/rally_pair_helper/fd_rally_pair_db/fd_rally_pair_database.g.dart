// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fd_rally_pair_database.dart';

// ignore_for_file: type=lint
class $FdRallyPairSessionsTable extends FdRallyPairSessions
    with TableInfo<$FdRallyPairSessionsTable, FdRallyPairSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FdRallyPairSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    courtCount,
    pairingPolicy,
    scorePreset,
    avoidRecentPartner,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fd_rally_pair_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FdRallyPairSession> instance, {
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
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  FdRallyPairSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FdRallyPairSession(
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
      avoidRecentPartner: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}avoid_recent_partner'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FdRallyPairSessionsTable createAlias(String alias) {
    return $FdRallyPairSessionsTable(attachedDatabase, alias);
  }
}

class FdRallyPairSession extends DataClass
    implements Insertable<FdRallyPairSession> {
  final int id;
  final String title;
  final int courtCount;
  final String pairingPolicy;
  final String scorePreset;
  final bool avoidRecentPartner;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FdRallyPairSession({
    required this.id,
    required this.title,
    required this.courtCount,
    required this.pairingPolicy,
    required this.scorePreset,
    required this.avoidRecentPartner,
    required this.status,
    required this.createdAt,
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
    map['avoid_recent_partner'] = Variable<bool>(avoidRecentPartner);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FdRallyPairSessionsCompanion toCompanion(bool nullToAbsent) {
    return FdRallyPairSessionsCompanion(
      id: Value(id),
      title: Value(title),
      courtCount: Value(courtCount),
      pairingPolicy: Value(pairingPolicy),
      scorePreset: Value(scorePreset),
      avoidRecentPartner: Value(avoidRecentPartner),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FdRallyPairSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FdRallyPairSession(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      courtCount: serializer.fromJson<int>(json['courtCount']),
      pairingPolicy: serializer.fromJson<String>(json['pairingPolicy']),
      scorePreset: serializer.fromJson<String>(json['scorePreset']),
      avoidRecentPartner: serializer.fromJson<bool>(json['avoidRecentPartner']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
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
      'avoidRecentPartner': serializer.toJson<bool>(avoidRecentPartner),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FdRallyPairSession copyWith({
    int? id,
    String? title,
    int? courtCount,
    String? pairingPolicy,
    String? scorePreset,
    bool? avoidRecentPartner,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => FdRallyPairSession(
    id: id ?? this.id,
    title: title ?? this.title,
    courtCount: courtCount ?? this.courtCount,
    pairingPolicy: pairingPolicy ?? this.pairingPolicy,
    scorePreset: scorePreset ?? this.scorePreset,
    avoidRecentPartner: avoidRecentPartner ?? this.avoidRecentPartner,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FdRallyPairSession copyWithCompanion(FdRallyPairSessionsCompanion data) {
    return FdRallyPairSession(
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
      avoidRecentPartner: data.avoidRecentPartner.present
          ? data.avoidRecentPartner.value
          : this.avoidRecentPartner,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FdRallyPairSession(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('courtCount: $courtCount, ')
          ..write('pairingPolicy: $pairingPolicy, ')
          ..write('scorePreset: $scorePreset, ')
          ..write('avoidRecentPartner: $avoidRecentPartner, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
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
    avoidRecentPartner,
    status,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FdRallyPairSession &&
          other.id == this.id &&
          other.title == this.title &&
          other.courtCount == this.courtCount &&
          other.pairingPolicy == this.pairingPolicy &&
          other.scorePreset == this.scorePreset &&
          other.avoidRecentPartner == this.avoidRecentPartner &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FdRallyPairSessionsCompanion extends UpdateCompanion<FdRallyPairSession> {
  final Value<int> id;
  final Value<String> title;
  final Value<int> courtCount;
  final Value<String> pairingPolicy;
  final Value<String> scorePreset;
  final Value<bool> avoidRecentPartner;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const FdRallyPairSessionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.courtCount = const Value.absent(),
    this.pairingPolicy = const Value.absent(),
    this.scorePreset = const Value.absent(),
    this.avoidRecentPartner = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FdRallyPairSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required int courtCount,
    required String pairingPolicy,
    required String scorePreset,
    required bool avoidRecentPartner,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : title = Value(title),
       courtCount = Value(courtCount),
       pairingPolicy = Value(pairingPolicy),
       scorePreset = Value(scorePreset),
       avoidRecentPartner = Value(avoidRecentPartner),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FdRallyPairSession> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? courtCount,
    Expression<String>? pairingPolicy,
    Expression<String>? scorePreset,
    Expression<bool>? avoidRecentPartner,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (courtCount != null) 'court_count': courtCount,
      if (pairingPolicy != null) 'pairing_policy': pairingPolicy,
      if (scorePreset != null) 'score_preset': scorePreset,
      if (avoidRecentPartner != null)
        'avoid_recent_partner': avoidRecentPartner,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FdRallyPairSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<int>? courtCount,
    Value<String>? pairingPolicy,
    Value<String>? scorePreset,
    Value<bool>? avoidRecentPartner,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return FdRallyPairSessionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      courtCount: courtCount ?? this.courtCount,
      pairingPolicy: pairingPolicy ?? this.pairingPolicy,
      scorePreset: scorePreset ?? this.scorePreset,
      avoidRecentPartner: avoidRecentPartner ?? this.avoidRecentPartner,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
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
    if (avoidRecentPartner.present) {
      map['avoid_recent_partner'] = Variable<bool>(avoidRecentPartner.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FdRallyPairSessionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('courtCount: $courtCount, ')
          ..write('pairingPolicy: $pairingPolicy, ')
          ..write('scorePreset: $scorePreset, ')
          ..write('avoidRecentPartner: $avoidRecentPartner, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FdRallyPairPlayersTable extends FdRallyPairPlayers
    with TableInfo<$FdRallyPairPlayersTable, FdRallyPairPlayer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FdRallyPairPlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fd_rally_pair_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    displayName,
    normalizedName,
    state,
    queueOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fd_rally_pair_players';
  @override
  VerificationContext validateIntegrity(
    Insertable<FdRallyPairPlayer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
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
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sessionId, normalizedName},
  ];
  @override
  FdRallyPairPlayer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FdRallyPairPlayer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      queueOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}queue_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FdRallyPairPlayersTable createAlias(String alias) {
    return $FdRallyPairPlayersTable(attachedDatabase, alias);
  }
}

class FdRallyPairPlayer extends DataClass
    implements Insertable<FdRallyPairPlayer> {
  final int id;
  final int sessionId;
  final String displayName;
  final String normalizedName;
  final String state;
  final int queueOrder;
  final DateTime createdAt;
  const FdRallyPairPlayer({
    required this.id,
    required this.sessionId,
    required this.displayName,
    required this.normalizedName,
    required this.state,
    required this.queueOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['display_name'] = Variable<String>(displayName);
    map['normalized_name'] = Variable<String>(normalizedName);
    map['state'] = Variable<String>(state);
    map['queue_order'] = Variable<int>(queueOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FdRallyPairPlayersCompanion toCompanion(bool nullToAbsent) {
    return FdRallyPairPlayersCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      displayName: Value(displayName),
      normalizedName: Value(normalizedName),
      state: Value(state),
      queueOrder: Value(queueOrder),
      createdAt: Value(createdAt),
    );
  }

  factory FdRallyPairPlayer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FdRallyPairPlayer(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      state: serializer.fromJson<String>(json['state']),
      queueOrder: serializer.fromJson<int>(json['queueOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'displayName': serializer.toJson<String>(displayName),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'state': serializer.toJson<String>(state),
      'queueOrder': serializer.toJson<int>(queueOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FdRallyPairPlayer copyWith({
    int? id,
    int? sessionId,
    String? displayName,
    String? normalizedName,
    String? state,
    int? queueOrder,
    DateTime? createdAt,
  }) => FdRallyPairPlayer(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    displayName: displayName ?? this.displayName,
    normalizedName: normalizedName ?? this.normalizedName,
    state: state ?? this.state,
    queueOrder: queueOrder ?? this.queueOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  FdRallyPairPlayer copyWithCompanion(FdRallyPairPlayersCompanion data) {
    return FdRallyPairPlayer(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      state: data.state.present ? data.state.value : this.state,
      queueOrder: data.queueOrder.present
          ? data.queueOrder.value
          : this.queueOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FdRallyPairPlayer(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('displayName: $displayName, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('state: $state, ')
          ..write('queueOrder: $queueOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    displayName,
    normalizedName,
    state,
    queueOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FdRallyPairPlayer &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.displayName == this.displayName &&
          other.normalizedName == this.normalizedName &&
          other.state == this.state &&
          other.queueOrder == this.queueOrder &&
          other.createdAt == this.createdAt);
}

class FdRallyPairPlayersCompanion extends UpdateCompanion<FdRallyPairPlayer> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> displayName;
  final Value<String> normalizedName;
  final Value<String> state;
  final Value<int> queueOrder;
  final Value<DateTime> createdAt;
  const FdRallyPairPlayersCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.state = const Value.absent(),
    this.queueOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FdRallyPairPlayersCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String displayName,
    required String normalizedName,
    required String state,
    required int queueOrder,
    required DateTime createdAt,
  }) : sessionId = Value(sessionId),
       displayName = Value(displayName),
       normalizedName = Value(normalizedName),
       state = Value(state),
       queueOrder = Value(queueOrder),
       createdAt = Value(createdAt);
  static Insertable<FdRallyPairPlayer> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? displayName,
    Expression<String>? normalizedName,
    Expression<String>? state,
    Expression<int>? queueOrder,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (displayName != null) 'display_name': displayName,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (state != null) 'state': state,
      if (queueOrder != null) 'queue_order': queueOrder,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FdRallyPairPlayersCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<String>? displayName,
    Value<String>? normalizedName,
    Value<String>? state,
    Value<int>? queueOrder,
    Value<DateTime>? createdAt,
  }) {
    return FdRallyPairPlayersCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      displayName: displayName ?? this.displayName,
      normalizedName: normalizedName ?? this.normalizedName,
      state: state ?? this.state,
      queueOrder: queueOrder ?? this.queueOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (queueOrder.present) {
      map['queue_order'] = Variable<int>(queueOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FdRallyPairPlayersCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('displayName: $displayName, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('state: $state, ')
          ..write('queueOrder: $queueOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $FdRallyPairCourtsTable extends FdRallyPairCourts
    with TableInfo<$FdRallyPairCourtsTable, FdRallyPairCourt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FdRallyPairCourtsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fd_rally_pair_sessions (id) ON DELETE CASCADE',
    ),
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
  @override
  List<GeneratedColumn> get $columns => [id, sessionId, number, state];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fd_rally_pair_courts';
  @override
  VerificationContext validateIntegrity(
    Insertable<FdRallyPairCourt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sessionId, number},
  ];
  @override
  FdRallyPairCourt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FdRallyPairCourt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
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
    );
  }

  @override
  $FdRallyPairCourtsTable createAlias(String alias) {
    return $FdRallyPairCourtsTable(attachedDatabase, alias);
  }
}

class FdRallyPairCourt extends DataClass
    implements Insertable<FdRallyPairCourt> {
  final int id;
  final int sessionId;
  final int number;
  final String state;
  const FdRallyPairCourt({
    required this.id,
    required this.sessionId,
    required this.number,
    required this.state,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['number'] = Variable<int>(number);
    map['state'] = Variable<String>(state);
    return map;
  }

  FdRallyPairCourtsCompanion toCompanion(bool nullToAbsent) {
    return FdRallyPairCourtsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      number: Value(number),
      state: Value(state),
    );
  }

  factory FdRallyPairCourt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FdRallyPairCourt(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      number: serializer.fromJson<int>(json['number']),
      state: serializer.fromJson<String>(json['state']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'number': serializer.toJson<int>(number),
      'state': serializer.toJson<String>(state),
    };
  }

  FdRallyPairCourt copyWith({
    int? id,
    int? sessionId,
    int? number,
    String? state,
  }) => FdRallyPairCourt(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    number: number ?? this.number,
    state: state ?? this.state,
  );
  FdRallyPairCourt copyWithCompanion(FdRallyPairCourtsCompanion data) {
    return FdRallyPairCourt(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      number: data.number.present ? data.number.value : this.number,
      state: data.state.present ? data.state.value : this.state,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FdRallyPairCourt(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('number: $number, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, number, state);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FdRallyPairCourt &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.number == this.number &&
          other.state == this.state);
}

class FdRallyPairCourtsCompanion extends UpdateCompanion<FdRallyPairCourt> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> number;
  final Value<String> state;
  const FdRallyPairCourtsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.number = const Value.absent(),
    this.state = const Value.absent(),
  });
  FdRallyPairCourtsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int number,
    required String state,
  }) : sessionId = Value(sessionId),
       number = Value(number),
       state = Value(state);
  static Insertable<FdRallyPairCourt> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? number,
    Expression<String>? state,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (number != null) 'number': number,
      if (state != null) 'state': state,
    });
  }

  FdRallyPairCourtsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? number,
    Value<String>? state,
  }) {
    return FdRallyPairCourtsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      number: number ?? this.number,
      state: state ?? this.state,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FdRallyPairCourtsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('number: $number, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }
}

abstract class _$FdRallyPairDatabase extends GeneratedDatabase {
  _$FdRallyPairDatabase(QueryExecutor e) : super(e);
  late final $FdRallyPairSessionsTable fdRallyPairSessions =
      $FdRallyPairSessionsTable(this);
  late final $FdRallyPairPlayersTable fdRallyPairPlayers =
      $FdRallyPairPlayersTable(this);
  late final $FdRallyPairCourtsTable fdRallyPairCourts =
      $FdRallyPairCourtsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    fdRallyPairSessions,
    fdRallyPairPlayers,
    fdRallyPairCourts,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'fd_rally_pair_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('fd_rally_pair_players', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'fd_rally_pair_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('fd_rally_pair_courts', kind: UpdateKind.delete)],
    ),
  ]);
}
