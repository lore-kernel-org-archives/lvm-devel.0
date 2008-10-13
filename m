From: Petr Rockai <prockai@redhat.com>
Date: Mon, 13 Oct 2008 10:17:00 +0200
Subject: small cleanup to tests
In-Reply-To: <48EDECFC.1050801@gmail.com> (Danny Rawlins's message of "Thu, 09
	Oct 2008 22:37:32 +1100")
References: <48EDECFC.1050801@gmail.com>
Message-ID: <87ljws29kz.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

first off, thanks for looking at the tests, this is still an area that is
somewhat underestimated (but, we are working on it).

Danny Rawlins <monster.romster@gmail.com> writes:
> I've added a VERBOSE option for show/hide the test instead of editing
> the file every time to change it. defaulted to show. and cleaned up
> indentation on the last commit i saw to test.
The verbosity is hardcoded on purpose, since the test itself shows up on test
output. Moreover, it is only really useful when debugging the utility
functions, less so when debugging test failures. I am ambivalent... It might
get flopped on by accident, since the last checkin was quite in a hurry.

Indentation cleanups, please keep them in separate patches. I know indentation
is currently broken, but I'd prefer to not mix it up with functional changes.

I will get to the testsuite again this week and will try to clean up any
collateral from the last set of checkins (including that bash dependency we
have reintroduced).

Yours,
   Petr.


-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


