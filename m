From: Killian De Volder <killian.de.volder@megasoft.be>
Date: Thu, 22 Mar 2012 08:17:37 +0100
Subject: liblvm Python/C extension (Python Liblvm)
Message-ID: <4F6AD211.3040807@megasoft.be>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

@Lars,
I'm rather interested in this, have there been any updates ?

@The community,
Are there any plans for allowing python binding in the lvm-sources, or should this be a separate package ?
I also detect no way in lvm2app to create for example a snapshot. So I'm going to assume there is also need for work here.
Or is C binding of LVM generally a bad idea, and should we instead parse the lvm-tool output and communicate with LVM trough those means ?

Feedback is welcome of course.

Kind regards,
Killian De Volder

>  Hello,
>
>  I was missing a proper LVM2 interface to Python so I decided to write
>  one my self! I have wrapped all the liblvm C APIs (excluding the new
>  APIs committed in Dec). Doc strings are still missing, as well as proper
>  setup.py build env, so consider it as work in progress.
>
>  This might also be interesting to other projects like Anaconda for
>  example.
>
>  I would love to get your feedback on it!
>
>  Best regards,
>  Lars


