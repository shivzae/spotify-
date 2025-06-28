--EDA
select*from spotify;

select count(*)from spotify;

select count (distinct artist)from spotify;

select count (distinct album)from spotify;

select distinct album_type from spotify;

select max (duration_min),min(duration_min) from spotify;

select*from spotify 
where duration_min=0;

delete from spotify
where duration_min=0;
select*from spotify 
where duration_min=0;

select distinct channel from spotify;

select distinct most_played_on from spotify;
--------------------------------------------
-- Data Analysis--
--------------------------------------------

--q.1 Retrieve the names of all tracks that have more than 1 billion streams.
select * from spotify 
where stream >1000000000;

--q.2 List all albums along with their respective artists.
select album,artist from spotify ;

--q.3 Get the total number of comments for tracks where licensed = TRUE.
select sum(comments) as total_comments from spotify
where licensed='true'; 

--q.4 Find all tracks that belong to the album type single.
select track from spotify 
where album_type='single';

---q.5 Count the total number of tracks by each artist.
select artist,count(track)as total_tracks from spotify
group by artist ;

-- q.6 Calculate the average danceability of tracks in each album.
select album,avg(danceability) as avg_danceability from spotify 
group by 1 
order by 2 desc; 

--q.7 Find the top 5 tracks with the highest energy values.
select track , energy from spotify
order by energy desc
limit 5;

--q.8 List all tracks along with their views and likes where official_video = TRUE.

select track,
sum(views) as total_views,
sum(likes) as total_likes 
from spotify
where official_video='true'
group by 1
order by 2 desc ;

--q.9 For each album, calculate the total views of all associated tracks.

select album,
track,
sum(views ) as total_views
from spotify 
group by 1, 2 ;

--q.10 Retrieve the track names that have been streamed on Spotify more than YouTube.
select * from 
(select track,
coalesce(sum(case when most_played_on ='Youtube'then stream end),0) as streamed_on_yt , 
coalesce(sum(case when most_played_on ='Spotify'then stream end),0) as streamed_on_spotify 
from spotify
group by 1 ) as t1 
where streamed_on_spotify>streamed_on_yt
and streamed_on_yt <>0;

-- q.11 Find the top 3 most-viewed tracks for each artist using window functions.

with ranking_artist
as
(select artist, track, sum(views) as total_view,
dense_rank() over(partition by artist order by sum(views)) as rank 
from spotify
group by 1, 2
order by 1,3 desc )
select*from ranking_artist where rank<=3;

--q.12 Write a query to find tracks where the liveness score is above the average.

select artist,track,liveness from spotify 
where liveness>
(select avg(liveness)from spotify );

-- q.13
--Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH cte
AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energery
FROM spotify
GROUP BY 1
)
SELECT 
	album,
	highest_energy - lowest_energery as energy_diff
FROM cte
ORDER BY 2 DESC;

--q.14 Find tracks where the energy-to-liveness ratio is greater than 1.2.
SELECT track
FROM spotify
WHERE energy / NULLIF(liveness, 0) > 1.2;

--q.15 Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
SELECT 
    track,
    views,
    likes,
    SUM(likes) OVER (ORDER BY views) AS cumulative_likes
FROM spotify;

-- q. 16 Which tracks are most likely to be good for dance playlists 
SELECT track, artist, danceability, speechiness
FROM spotify
WHERE danceability > 0.8 AND speechiness < 0.1
ORDER BY danceability DESC;

-- q. 17  Which official music videos are not performing well despite being licensed and official?
SELECT track, artist, views, likes, comments
FROM spotify
WHERE official_video = TRUE AND licensed = TRUE
  AND views < 100000  
ORDER BY views ASC;

-- q.18 Which artists are generating the most streams across all their tracks?
SELECT artist,
       SUM(stream) AS total_streams
FROM spotify
GROUP BY artist
ORDER BY total_streams DESC
LIMIT 10;

--q.19 Do longer or shorter tracks tend to get more views?
SELECT 
    duration_min,
    AVG(views) AS avg_views
FROM spotify
GROUP BY duration_min
ORDER BY duration_min;

--q.20 which track per artist has generated the most user interaction (comments)?

SELECT DISTINCT ON (artist)
    artist,
    track,
    comments
FROM spotify
ORDER BY artist, comments DESC;


