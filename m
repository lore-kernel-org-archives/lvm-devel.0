From: haaber <haaber@web.de>
Date: Tue, 23 May 2023 17:24:55 +0200
Subject: [SOLVED] Data recovery -- thin provisioned LVM metadata (?) problem after hardware failure
In-Reply-To: <CALjSBEsSC4X7aeZuNRuTjhY9OZ6d_z=PymBycQ+sBh0ftzmrGQ@mail.gmail.com>
References: <54726276-8f4e-7538-f0b5-e825920a0357@web.de>
 <b987f331-b2c8-ed18-14eb-e039830ed436@gmail.com>
 <7de7fbb2-7c52-4564-e63e-e4c1523962f7@web.de>
 <5b8439e8-f7a0-c9c3-cdc8-257ee68db41c@redhat.com>
 <0c82e706-8051-d131-91fb-f8f5556d88e7@web.de>
 <0780dc89-f6b8-e204-18c3-12e404aeaaff@gmail.com>
 <6c1b291d-b4e4-4698-b9b4-63c43e9e484d@web.de>
 <2b1b2d49-fe46-e544-03d3-79b831df4a52@gmail.com>
 <3ce7f8b3-8c37-8b5f-a4f4-b088baedbb65@web.de>
 <CALjSBEsTnEdGx70-QFz-pLO42he=O1-dys9iRcg7ytKk8SnKKQ@mail.gmail.com>
 <2a1a3e85-ba19-5f79-735e-fe518aa03b94@web.de>
 <CALjSBEsSC4X7aeZuNRuTjhY9OZ6d_z=PymBycQ+sBh0ftzmrGQ@mail.gmail.com>
Message-ID: <cb530b76-6a9e-612b-2369-c1b2de97070f@web.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dear Ming, Zdenek and others,

On 5/22/23 09:40, Ming Hung Tsai wrote:
> lvconvert qubes_dom0/pool00 --swapmetadata --poolmetadata qubes_dom0/newlv

issue solved, thank you SO MUCH! Just copying all data to a new drive :)

best, Bernhard


