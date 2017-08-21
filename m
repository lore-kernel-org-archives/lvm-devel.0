From: Anatoly Pugachev <matorola@gmail.com>
Date: Mon, 21 Aug 2017 17:42:44 +0300
Subject: [xfstests, sparc64] git kernel OOPS 4.13.0-rc5+
In-Reply-To: <CADxRZqyTse068Pt8xsAyehEJoHA7jQ6vPH4WCVyxrzEjYjpA1Q@mail.gmail.com>
References: <CADxRZqykqGycgPh5O9C1F_Eq0J_rP-95zxesDkSDbkLD=04uYA@mail.gmail.com>
	<CADxRZqz_m69YL214tiimqCQ-+pYAvc1UFO_HgvTdKKok0_LzXw@mail.gmail.com>
	<CADxRZqyHkwT+HVTQopDZYiAwkCAkBDvPM0eY-Cqw6e5XuzcZ5Q@mail.gmail.com>
	<CADxRZqwe71WZ2=9Xecash65zdk2HmaRffoiCWjwQCHzub3tdvQ@mail.gmail.com>
	<CADxRZqyTse068Pt8xsAyehEJoHA7jQ6vPH4WCVyxrzEjYjpA1Q@mail.gmail.com>
Message-ID: <CADxRZqwRL1tQ=6KGDzTFJt62bWQ_eN__Yu8UF02pk0beFejwoQ@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Compiling git kernel with gcc-7.2 and with patch [1] fixes OOPS on
xfstests as well.

1. "[sparc64] kernel OOPS with gcc 7.1 / 7.2"
https://marc.info/?l=gcc&m=150285790205560&w=2


