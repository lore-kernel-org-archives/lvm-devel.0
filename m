From: Marian Csontos <mcsontos@redhat.com>
Date: Thu, 10 May 2018 14:07:23 +0200
Subject: boom packaging question
Message-ID: <068965e5-0e34-0d7f-a1a5-d55db0200895@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Bryn, I do wonder, shall we treat files in /boot/loader/entries and 
/boot/boom/profiles as user data?

There are multiple reasons for that:

- If one for whatever reason removes boom package, shall we keep 
/boot/loader/entries? I think rather Yes.

- If there are multiple linux distribution installed, could they 
potentially fight over this directory and its content? Maybe...

- OsProfiles are similar and IMO even more relevant. User will likely 
need to change those (e.g at least remove rhgb and quiet from kernel 
cmdline, and/or add rd.luks.uuid), so if not data, we should treat them 
more like config files with backups, and we should not replace them on 
updates.

What can we do?

- I am not sure OS/RPM would be happy about %config files in /boot :-|
     - *TODO:* Test it even works!

- And we want to share those among OSes and boot-sessions, so we MUST 
keep them outside of / and in shared (/boot) directory.

-- Martian


