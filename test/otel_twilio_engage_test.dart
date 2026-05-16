// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_twilio_engage/otel_twilio_engage.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_twilio_engage-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('audiences.size records audience + size + mtus', () async {
    await tracedTwilioEngage<String>(
      operation: 'audiences.size',
      invoke: () async => const TwilioEngageCallResult(
        value: 'ok',
        result: TwilioEngageResult(
          workspaceSlug: 'acme',
          spaceId: 'spa_1',
          audienceId: 'aud_1',
          audienceKey: 'high_value_customers',
          audienceType: 'LIVE',
          computationClass: 'audience',
          entityKind: 'audience',
          profileSize: 1500000,
          audienceSize: 42000,
          mtus: 42000,
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('twilio_engage audiences.size')!);
    expect(a['twilio_engage.audience.key'], 'high_value_customers');
    expect(a['twilio_engage.audience.type'], 'LIVE');
    expect(a['twilio_engage.audience.size'], 42000);
    expect(a['twilio_engage.mtus'], 42000);
  });

  test('event_sources.send records ingestion count', () async {
    await tracedTwilioEngage<String>(
      operation: 'event_sources.send',
      invoke: () async => const TwilioEngageCallResult(
        value: 'ok',
        result: TwilioEngageResult(
          spaceId: 'spa_1',
          entityKind: 'event_source',
          eventsIngested: 500,
          statusCode: 200,
        ),
      ),
    );
    final a =
        attrsOf(spans.findSpanByName('twilio_engage event_sources.send')!);
    expect(a['twilio_engage.events.ingested'], 500);
  });

  test('HTTP 429 sets span error', () async {
    await tracedTwilioEngage<String>(
      operation: 'profiles.events',
      invoke: () async => const TwilioEngageCallResult(
        value: 'ok',
        result: TwilioEngageResult(statusCode: 429),
      ),
    );
    expect(
      spans.findSpanByName('twilio_engage profiles.events')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutTwilioEngageInstrumentationAsync(() async {
      await tracedTwilioEngage<String>(
        operation: 'audiences.list',
        invoke: () async => const TwilioEngageCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('twilio_engage '), isEmpty);
  });
}
