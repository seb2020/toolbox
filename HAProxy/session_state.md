# Session state at disconnection


TCP and HTTP logs provide a session termination indicator in the
"termination_state" field, just before the number of active connections. It is
2-characters long in TCP mode, and is extended to 4 characters in HTTP mode,
each of which has a special meaning :

  - On the first character, a code reporting the first event which caused the
    session to terminate :

        C : the TCP session was unexpectedly aborted by the client.

        S : the TCP session was unexpectedly aborted by the server, or the
            server explicitly refused it.

        P : the session was prematurely aborted by the proxy, because of a
            connection limit enforcement, because a DENY filter was matched,
            because of a security check which detected and blocked a dangerous
            error in server response which might have caused information leak
            (eg: cacheable cookie), or because the response was processed by
            the proxy (redirect, stats, etc...).

        R : a resource on the proxy has been exhausted (memory, sockets, source
            ports, ...). Usually, this appears during the connection phase, and
            system logs should contain a copy of the precise error. If this
            happens, it must be considered as a very serious anomaly which
            should be fixed as soon as possible by any means.

        I : an internal error was identified by the proxy during a self-check.
            This should NEVER happen, and you are encouraged to report any log
            containing this, because this would almost certainly be a bug. It
            would be wise to preventively restart the process after such an
            event too, in case it would be caused by memory corruption.

        c : the client-side timeout expired while waiting for the client to
            send or receive data.

        s : the server-side timeout expired while waiting for the server to
            send or receive data.

        - : normal session completion, both the client and the server closed
            with nothing left in the buffers.

  - on the second character, the TCP or HTTP session state when it was closed :

        R : the proxy was waiting for a complete, valid REQUEST from the client
            (HTTP mode only). Nothing was sent to any server.

        Q : the proxy was waiting in the QUEUE for a connection slot. This can
            only happen when servers have a 'maxconn' parameter set. It can
            also happen in the global queue after a redispatch consecutive to
            a failed attempt to connect to a dying server. If no redispatch is
            reported, then no connection attempt was made to any server.

        C : the proxy was waiting for the CONNECTION to establish on the
            server. The server might at most have noticed a connection attempt.

        H : the proxy was waiting for complete, valid response HEADERS from the
            server (HTTP only).

        D : the session was in the DATA phase.

        L : the proxy was still transmitting LAST data to the client while the
            server had already finished. This one is very rare as it can only
            happen when the client dies while receiving the last packets.

        T : the request was tarpitted. It has been held open with the client
            during the whole "timeout tarpit" duration or until the client
            closed, both of which will be reported in the "Tw" timer.

        - : normal session completion after end of data transfer.

  - the third character tells whether the persistence cookie was provided by
    the client (only in HTTP mode) :

        N : the client provided NO cookie. This is usually the case for new
            visitors, so counting the number of occurrences of this flag in the
            logs generally indicate a valid trend for the site frequentation.

        I : the client provided an INVALID cookie matching no known server.
            This might be caused by a recent configuration change, mixed
            cookies between HTTP/HTTPS sites, persistence conditionally
            ignored, or an attack.

        D : the client provided a cookie designating a server which was DOWN,
            so either "option persist" was used and the client was sent to
            this server, or it was not set and the client was redispatched to
            another server.

        V : the client provided a VALID cookie, and was sent to the associated
            server.

        E : the client provided a valid cookie, but with a last date which was
            older than what is allowed by the "maxidle" cookie parameter, so
            the cookie is consider EXPIRED and is ignored. The request will be
            redispatched just as if there was no cookie.

        O : the client provided a valid cookie, but with a first date which was
            older than what is allowed by the "maxlife" cookie parameter, so
            the cookie is consider too OLD and is ignored. The request will be
            redispatched just as if there was no cookie.

        - : does not apply (no cookie set in configuration).

  - the last character reports what operations were performed on the persistence
    cookie returned by the server (only in HTTP mode) :

        N : NO cookie was provided by the server, and none was inserted either.

        I : no cookie was provided by the server, and the proxy INSERTED one.
            Note that in "cookie insert" mode, if the server provides a cookie,
            it will still be overwritten and reported as "I" here.

        U : the proxy UPDATED the last date in the cookie that was presented by
            the client. This can only happen in insert mode with "maxidle". It
            happens everytime there is activity at a different date than the
            date indicated in the cookie. If any other change happens, such as
            a redispatch, then the cookie will be marked as inserted instead.

        P : a cookie was PROVIDED by the server and transmitted as-is.

        R : the cookie provided by the server was REWRITTEN by the proxy, which
            happens in "cookie rewrite" or "cookie prefix" modes.

        D : the cookie provided by the server was DELETED by the proxy.

        - : does not apply (no cookie set in configuration).

The combination of the two first flags gives a lot of information about what
was happening when the session terminated, and why it did terminate. It can be
helpful to detect server saturation, network troubles, local system resource
starvation, attacks, etc...

The most common termination flags combinations are indicated below. They are
alphabetically sorted, with the lowercase set just after the upper case for
easier finding and understanding.

  Flags   Reason

     --   Normal termination.

     CC   The client aborted before the connection could be established to the
          server. This can happen when haproxy tries to connect to a recently
          dead (or unchecked) server, and the client aborts while haproxy is
          waiting for the server to respond or for "timeout connect" to expire.

     CD   The client unexpectedly aborted during data transfer. This can be
          caused by a browser crash, by an intermediate equipment between the
          client and haproxy which decided to actively break the connection,
          by network routing issues between the client and haproxy, or by a
          keep-alive session between the server and the client terminated first
          by the client.

     cD   The client did not send nor acknowledge any data for as long as the
          "timeout client" delay. This is often caused by network failures on
	  the client side, or the client simply leaving the net uncleanly.

     CH   The client aborted while waiting for the server to start responding.
          It might be the server taking too long to respond or the client
          clicking the 'Stop' button too fast.

     cH   The "timeout client" stroke while waiting for client data during a
          POST request. This is sometimes caused by too large TCP MSS values
          for PPPoE networks which cannot transport full-sized packets. It can
          also happen when client timeout is smaller than server timeout and
          the server takes too long to respond.

     CQ   The client aborted while its session was queued, waiting for a server
          with enough empty slots to accept it. It might be that either all the
          servers were saturated or that the assigned server was taking too
          long a time to respond.

     CR   The client aborted before sending a full HTTP request. Most likely
          the request was typed by hand using a telnet client, and aborted
          too early. The HTTP status code is likely a 400 here. Sometimes this
          might also be caused by an IDS killing the connection between haproxy
          and the client.

     cR   The "timeout http-request" stroke before the client sent a full HTTP
          request. This is sometimes caused by too large TCP MSS values on the
          client side for PPPoE networks which cannot transport full-sized
          packets, or by clients sending requests by hand and not typing fast
          enough, or forgetting to enter the empty line at the end of the
          request. The HTTP status code is likely a 408 here.

     CT   The client aborted while its session was tarpitted. It is important to
          check if this happens on valid requests, in order to be sure that no
          wrong tarpit rules have been written. If a lot of them happen, it
          might make sense to lower the "timeout tarpit" value to something
          closer to the average reported "Tw" timer, in order not to consume
          resources for just a few attackers.

     SC   The server or an equipment between it and haproxy explicitly refused
          the TCP connection (the proxy received a TCP RST or an ICMP message
          in return). Under some circumstances, it can also be the network
          stack telling the proxy that the server is unreachable (eg: no route,
          or no ARP response on local network). When this happens in HTTP mode,
          the status code is likely a 502 or 503 here.

     sC   The "timeout connect" stroke before a connection to the server could
          complete. When this happens in HTTP mode, the status code is likely a
          503 or 504 here.

     SD   The connection to the server died with an error during the data
          transfer. This usually means that haproxy has received an RST from
          the server or an ICMP message from an intermediate equipment while
          exchanging data with the server. This can be caused by a server crash
          or by a network issue on an intermediate equipment.

     sD   The server did not send nor acknowledge any data for as long as the
          "timeout server" setting during the data phase. This is often caused
          by too short timeouts on L4 equipments before the server (firewalls,
          load-balancers, ...), as well as keep-alive sessions maintained
          between the client and the server expiring first on haproxy.

     SH   The server aborted before sending its full HTTP response headers, or
          it crashed while processing the request. Since a server aborting at
          this moment is very rare, it would be wise to inspect its logs to
          control whether it crashed and why. The logged request may indicate a
          small set of faulty requests, demonstrating bugs in the application.
          Sometimes this might also be caused by an IDS killing the connection
          between haproxy and the server.

     sH   The "timeout server" stroke before the server could return its
          response headers. This is the most common anomaly, indicating too
          long transactions, probably caused by server or database saturation.
          The immediate workaround consists in increasing the "timeout server"
          setting, but it is important to keep in mind that the user experience
          will suffer from these long response times. The only long term
          solution is to fix the application.

     sQ   The session spent too much time in queue and has been expired. See
          the "timeout queue" and "timeout connect" settings to find out how to
          fix this if it happens too often. If it often happens massively in
          short periods, it may indicate general problems on the affected
          servers due to I/O or database congestion, or saturation caused by
          external attacks.

     PC   The proxy refused to establish a connection to the server because the
          process' socket limit has been reached while attempting to connect.
	  The global "maxconn" parameter may be increased in the configuration
          so that it does not happen anymore. This status is very rare and
          might happen when the global "ulimit-n" parameter is forced by hand.

     PD   The proxy blocked an incorrectly formatted chunked encoded message in
          a request or a response, after the server has emitted its headers. In
          most cases, this will indicate an invalid message from the server to
          the client.

     PH   The proxy blocked the server's response, because it was invalid,
          incomplete, dangerous (cache control), or matched a security filter.
          In any case, an HTTP 502 error is sent to the client. One possible
          cause for this error is an invalid syntax in an HTTP header name
          containing unauthorized characters. It is also possible but quite
          rare, that the proxy blocked a chunked-encoding request from the
          client due to an invalid syntax, before the server responded. In this
          case, an HTTP 400 error is sent to the client and reported in the
          logs.

     PR   The proxy blocked the client's HTTP request, either because of an
          invalid HTTP syntax, in which case it returned an HTTP 400 error to
          the client, or because a deny filter matched, in which case it
          returned an HTTP 403 error.

     PT   The proxy blocked the client's request and has tarpitted its
          connection before returning it a 500 server error. Nothing was sent
          to the server. The connection was maintained open for as long as
          reported by the "Tw" timer field.

     RC   A local resource has been exhausted (memory, sockets, source ports)
          preventing the connection to the server from establishing. The error
          logs will tell precisely what was missing. This is very rare and can
          only be solved by proper system tuning.

The combination of the two last flags gives a lot of information about how
persistence was handled by the client, the server and by haproxy. This is very
important to troubleshoot disconnections, when users complain they have to
re-authenticate. The commonly encountered flags are :

     --   Persistence cookie is not enabled.

     NN   No cookie was provided by the client, none was inserted in the
          response. For instance, this can be in insert mode with "postonly"
          set on a GET request.

     II   A cookie designating an invalid server was provided by the client,
          a valid one was inserted in the response. This typically happens when
          a "server" entry is removed from the configuraton, since its cookie
          value can be presented by a client when no other server knows it.

     NI   No cookie was provided by the client, one was inserted in the
          response. This typically happens for first requests from every user
          in "insert" mode, which makes it an easy way to count real users.

     VN   A cookie was provided by the client, none was inserted in the
          response. This happens for most responses for which the client has
          already got a cookie.

     VU   A cookie was provided by the client, with a last visit date which is
          not completely up-to-date, so an updated cookie was provided in
          response. This can also happen if there was no date at all, or if
          there was a date but the "maxidle" parameter was not set, so that the
          cookie can be switched to unlimited time.

     EI   A cookie was provided by the client, with a last visit date which is
          too old for the "maxidle" parameter, so the cookie was ignored and a
          new cookie was inserted in the response.

     OI   A cookie was provided by the client, with a first visit date which is
          too old for the "maxlife" parameter, so the cookie was ignored and a
          new cookie was inserted in the response.

     DI   The server designated by the cookie was down, a new server was
          selected and a new cookie was emitted in the response.

     VI   The server designated by the cookie was not marked dead but could not
          be reached. A redispatch happened and selected another one, which was
          then advertised in the response.