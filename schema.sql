
create table voter (
	state char(2),
	ac smallint,
	pb smallint,
	voterid text	
);

create index voter_idx on voter(voterid);
