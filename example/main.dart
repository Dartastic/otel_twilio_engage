// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_twilio_engage/otel_twilio_engage.dart';

/// Traces Twilio Engage / Segment Personas calls with OpenTelemetry.
///
/// `otel_twilio_engage` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Twilio Engage / Segment Personas call in
/// [tracedTwilioEngage]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'twilio-engage-example');

  // Wraps a Twilio Engage / Segment Personas API call in a CLIENT span.
  final twilioEngageId = await tracedTwilioEngage<String>(
    operation: 'audiences.create',
    invoke: () async {
      // Make the Twilio Engage / Segment Personas call here, then report what it returned.
      const id = 'twilio_engage_8f3a2c';
      return const TwilioEngageCallResult(
          value: id,
          result: TwilioEngageResult(
              workspaceSlug: 'example',
              spaceId: 'space_8f3a2c',
              profileId: 'profile_8f3a2c',
              audienceId: 'audience_8f3a2c',
              audienceKey: 'orders/2026/inv-1042.pdf',
              audienceType: 'LIVE',
              computationKey: 'total_orders_30d',
              computationClass: 'audience',
              journeyId: 'journey_8f3a2c',
              entityKind: 'profile',
              profileSize: 512,
              audienceSize: 512,
              eventsIngested: 1,
              computeDurationMs: 120,
              mtus: 1,
              statusCode: 201));
    },
  );
  OTelLog.info('tracedTwilioEngage audiences.create returned $twilioEngageId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutTwilioEngageInstrumentationAsync.
  await runWithoutTwilioEngageInstrumentationAsync(
    () => tracedTwilioEngage<String>(
      operation: 'audiences.create',
      invoke: () async {
        const id = 'twilio_engage_8f3a2c';
        return const TwilioEngageCallResult(
            value: id,
            result: TwilioEngageResult(
                workspaceSlug: 'example',
                spaceId: 'space_8f3a2c',
                profileId: 'profile_8f3a2c',
                audienceId: 'audience_8f3a2c',
                audienceKey: 'orders/2026/inv-1042.pdf',
                audienceType: 'LIVE',
                computationKey: 'total_orders_30d',
                computationClass: 'audience',
                journeyId: 'journey_8f3a2c',
                entityKind: 'profile',
                profileSize: 512,
                audienceSize: 512,
                eventsIngested: 1,
                computeDurationMs: 120,
                mtus: 1,
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
