From: Bastian Blank <bastian@waldi.eu.org>
Date: Sat, 10 Oct 2009 11:16:54 +0200
Subject: Usage of sysV semaphores
Message-ID: <20091010091654.GA26029@wavehammer.waldi.eu.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

Yesterday I tried to understand the udev sync code and played with it.
I'm not impressed as it broke rather spectacular.

Okay, lets start.

It uses a 32 bit value to synchronize itself. This value needs to make
two things possible: find our own values and distiguish between them.
- Find our own values
  This is done by a 16 bit magic, so a truly random value have a 1/2**16
  probability to reach the dm namespace. This is not good but okay.
- Distiguish between them
  Because of the birthday paradox the probability of conflicting values
  becomes 0.5 with only 2**8 concurent events. Peter spoke about
  hundreds or even thousands of possible flying events, so this is
  relevant and will produce busy looping to find a free one.

SysV semaphore operations are not interruptible. So if something goes
wrong, and according to Murphy it will, the user is left with a process
that can only be killed by SIGKILL and is then not able to clean up
after itself. I'm not sure why, but this was one of the first things
that happened to me during testing.

SysV semaphores are a restricted ressource because they are not cleaned
up upon process exit. So random devmapper usage can just fail with a
message about a, from the user view, completely unrelated ressource.

This problems are bad from the user perspective, because he gets
non-responding or even unkillable processed. If he was able to kill
them, they will leave global ressources behind.

Bastian

-- 
Killing is wrong.
		-- Losira, "That Which Survives", stardate unknown


