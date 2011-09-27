From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 27 Sep 2011 17:41:58 +0200
Subject: [PATCH v3 02/18] fsadm: Make all internal math in kilobytes
In-Reply-To: <1317130971-24173-3-git-send-email-lczerner@redhat.com>
References: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
	<1317130971-24173-3-git-send-email-lczerner@redhat.com>
Message-ID: <4E81EEC6.1010904@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 27.9.2011 15:42, Lukas Czerner napsal(a):
> We should make all math in fsadm to count with kilobytes (if possible)
> because it will bypass the problem of having too big numbers. Also the
> smaller granularity might have troubles with 512B alignment.


I don't like this one -  if you have problems with big numbers - bugreport
bash. You are probably covering up different bug here.


Zdenek


