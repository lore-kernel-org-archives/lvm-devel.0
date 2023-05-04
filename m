From: haaber <haaber@web.de>
Date: Thu, 4 May 2023 19:06:50 +0200
Subject: Data recovery -- thin provisioned LVM metadata (?) problem after hardware failure
In-Reply-To: <0780dc89-f6b8-e204-18c3-12e404aeaaff@gmail.com>
References: <54726276-8f4e-7538-f0b5-e825920a0357@web.de>
 <b987f331-b2c8-ed18-14eb-e039830ed436@gmail.com>
 <7de7fbb2-7c52-4564-e63e-e4c1523962f7@web.de>
 <5b8439e8-f7a0-c9c3-cdc8-257ee68db41c@redhat.com>
 <0c82e706-8051-d131-91fb-f8f5556d88e7@web.de>
 <0780dc89-f6b8-e204-18c3-12e404aeaaff@gmail.com>
Message-ID: <6c1b291d-b4e4-4698-b9b4-63c43e9e484d@web.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dear Zdenek,

here https://we.tl/t-41PiPG2V1G???? is the output of

#thin_dump?? /dev/qubes_dom0/pool00_tmeta? > pool00_tmeta

metadata contains errors (run thin_check for details).

perhaps you wanted to run with --repairmetadata contains errors (run
thin_check for details).

perhaps you wanted to run with --repair


best, Bernhard





