From: Petr Rockai <prockai@redhat.com>
Date: Tue, 12 Oct 2010 18:05:14 +0200
Subject: [PATCH] dmeventd -R (restart; BZ 454618)
In-Reply-To: <874od0dclc.wl%ejt@redhat.com> (ejt@redhat.com's message of "Tue, 
	05 Oct 2010 13:54:23 +0100")
References: <874od0dclc.wl%ejt@redhat.com>
Message-ID: <87aamjv1l1.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

ejt at redhat.com writes:
> Do you think there are any unit tests you could write for this?  For
> example you've made changes to libdevmapper-event.c, which being a
> library is presumably amenable to being unit tested?

Hmh. I am not entirely convinced that libdevmapper-event, of all the
libraries we have, is the right unit testing candidate (at least at the
moment)... Virtually all the API functionality of the library talks to
dmeventd behind the scenes, and if it is not running, runs it. There
would be some options to unit test this, but we would need a private
dmeventd instance, since I would be quite uncomfortable with unit tests
talking to a system dmeventd. This needs some parametrisation of the
existing code, and additions to dmeventd command-line options (like,
where to put the communication FIFOs).

I can tack that onto my TODO, although it may be better to start with
unit testing elsewhere. I believe that the recent improvements in
dmeventd coverage in the functional suite are quite adequate. Of course,
we could do better, but there's also still room for improvement in the
functional suite, regarding dmeventd -- probably also easier to achieve
than with unit tests.

Yours,
   Petr.


