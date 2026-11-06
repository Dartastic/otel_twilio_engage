// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_twilio_engage_suppression.dart';

const _tracerName = 'dartastic_otel_libs_twilio_engage';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class TwilioEngageResult {
  /// Creates a result.
  const TwilioEngageResult({
    this.workspaceSlug,
    this.spaceId,
    this.profileId,
    this.audienceId,
    this.audienceKey,
    this.audienceType,
    this.computationKey,
    this.computationClass,
    this.journeyId,
    this.entityKind,
    this.profileSize,
    this.audienceSize,
    this.eventsIngested,
    this.computeDurationMs,
    this.mtus,
    this.statusCode,
  });

  /// Segment/Twilio Engage workspace slug.
  final String? workspaceSlug;

  /// Engage space (also called "personas space") within the workspace.
  final String? spaceId;

  /// Unified profile id (Segment's canonical identity).
  final String? profileId;

  final String? audienceId;
  final String? audienceKey;

  /// `LIVE` (streaming) / `BATCH`.
  final String? audienceType;

  /// Computation key (e.g., `total_orders_30d`) — for traits and
  /// audiences that compute over event history.
  final String? computationKey;

  /// `audience` / `trait` / `event` — what's being computed.
  final String? computationClass;

  /// Journey id (Engage's orchestration unit).
  final String? journeyId;

  /// `profile` / `audience` / `trait` / `journey` / `destination` /
  /// `event_source` — operation target.
  final String? entityKind;

  /// Total profiles in the space.
  final int? profileSize;

  /// Count of profiles currently matching the audience.
  final int? audienceSize;

  /// Events ingested in this call (e.g., from `events.send`).
  final int? eventsIngested;

  final int? computeDurationMs;

  /// Monthly tracked users delta — Engage's primary billing unit.
  final int? mtus;

  final int? statusCode;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class TwilioEngageCallResult<T> {
  /// Creates a call result.
  const TwilioEngageCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final TwilioEngageResult? result;
}

/// Wraps a Twilio Engage / Segment Personas API call in a CLIENT
/// span. [operation] is one of `profiles.get`, `profiles.list`,
/// `profiles.traits`, `profiles.events`, `audiences.create`,
/// `audiences.list`, `audiences.preview`, `audiences.size`,
/// `journeys.create`, `journeys.start`, `destinations.list`,
/// `event_sources.send`.
Future<T> tracedTwilioEngage<T>({
  required String operation,
  required Future<TwilioEngageCallResult<T>> Function() invoke,
}) async {
  if (twilioEngageInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'twilio_engage',
    'rpc.method': operation,
    'twilio_engage.operation': operation,
  };

  final span = _tracer().startSpan(
    'twilio_engage $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.workspaceSlug != null) {
        extras.add(OTelAPI.attributeString(
          'twilio_engage.workspace.slug',
          r.result!.workspaceSlug!,
        ));
      }
      if (r.result!.spaceId != null) {
        extras.add(OTelAPI.attributeString(
          'twilio_engage.space.id',
          r.result!.spaceId!,
        ));
      }
      if (r.result!.profileId != null) {
        extras.add(OTelAPI.attributeString(
          'twilio_engage.profile.id',
          r.result!.profileId!,
        ));
      }
      if (r.result!.audienceId != null) {
        extras.add(OTelAPI.attributeString(
          'twilio_engage.audience.id',
          r.result!.audienceId!,
        ));
      }
      if (r.result!.audienceKey != null) {
        extras.add(OTelAPI.attributeString(
          'twilio_engage.audience.key',
          r.result!.audienceKey!,
        ));
      }
      if (r.result!.audienceType != null) {
        extras.add(OTelAPI.attributeString(
          'twilio_engage.audience.type',
          r.result!.audienceType!,
        ));
      }
      if (r.result!.computationKey != null) {
        extras.add(OTelAPI.attributeString(
          'twilio_engage.computation.key',
          r.result!.computationKey!,
        ));
      }
      if (r.result!.computationClass != null) {
        extras.add(OTelAPI.attributeString(
          'twilio_engage.computation.class',
          r.result!.computationClass!,
        ));
      }
      if (r.result!.journeyId != null) {
        extras.add(OTelAPI.attributeString(
          'twilio_engage.journey.id',
          r.result!.journeyId!,
        ));
      }
      if (r.result!.entityKind != null) {
        extras.add(OTelAPI.attributeString(
          'twilio_engage.entity.kind',
          r.result!.entityKind!,
        ));
      }
      if (r.result!.profileSize != null) {
        extras.add(OTelAPI.attributeInt(
          'twilio_engage.profile.size',
          r.result!.profileSize!,
        ));
      }
      if (r.result!.audienceSize != null) {
        extras.add(OTelAPI.attributeInt(
          'twilio_engage.audience.size',
          r.result!.audienceSize!,
        ));
      }
      if (r.result!.eventsIngested != null) {
        extras.add(OTelAPI.attributeInt(
          'twilio_engage.events.ingested',
          r.result!.eventsIngested!,
        ));
      }
      if (r.result!.computeDurationMs != null) {
        extras.add(OTelAPI.attributeInt(
          'twilio_engage.compute.duration_ms',
          r.result!.computeDurationMs!,
        ));
      }
      if (r.result!.mtus != null) {
        extras.add(OTelAPI.attributeInt(
          'twilio_engage.mtus',
          r.result!.mtus!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTelAPI.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Twilio Engage HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
