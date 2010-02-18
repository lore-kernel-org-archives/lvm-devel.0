From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 18 Feb 2010 10:19:54 +0100
Subject: lvm and locales memory issue
Message-ID: <4B7D063A.7070601@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

As we discussed yesterday at the confcall the problem with mlockall() and way
we cannot easily disable locales, because of posix complaince and
internationalized error message.

How about adding some global{} configure option ?

e.i.:  "use_plain_C_locales = 0/1"

defaulting to 0.

Anaconda and eventually system admin who cares about memory might easily
enable it by switching to 1 - it could be slightly more confortable then
writing wrapper scripts around lvm command for the same thing.

The question is how we implement this - either we delay activation of
setlocale until we read config - or  we just call setlocale("C"...) just
before mlockall() if this is set by configuration?

Any better idea?

Zdenek


