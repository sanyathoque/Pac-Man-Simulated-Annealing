function PacmanSA2NodeSelection5_flock_flank
close all
clc
% flock : 2 bots with with node selection, ie. withT or L junction selection. 
% Node selection varies with increasing temperature, as bots heat
% increases, node selection changes. 
%1st Scene
% load standard game data
gameData = load('gameData.mat');

overallEnemySpeed = 1/16;   % standard ghost speed, 
grumpyTime = 700;           % time-increments that ghosts stay grumpy for
grumpyTimeSwitch = 200;     % time-increments that grumpy ghosts show that they are going to turn normal again
newEnemyTime = 500;         % time-increments that pass before the next ghost is let out of his cage
game.speed = 0.025;         % game speed (time-increment between two frames) maximum possible without lag on my machine: 0.008

pacman.speed = 1/14;        
if any(strcmp(listfonts,'Courier New'))
    pacFont = 'Courier New';
else
    pacFont = 'Arial';
end

% create figure
screen_size = get(0,'ScreenSize');                  % get screen size
figure_size = [650 650];                            % figure-size
limit_left = screen_size(3)/2-figure_size(1)/2;     % figure centered horizontally
limit_down = screen_size(4)/2-figure_size(2)/2;     % figure centered vertically
pacman_Fig = figure('units','pixels','Position',[limit_left limit_down figure_size(1) figure_size(2)],...  
    'Color','k','Resize','on','MenuBar','none','Visible','on',...
    'NumberTitle','off','Name','Pacman','doublebuffer','on',...
    'KeyPressFcn',@KeyAction,...                % Keyboard-Callback
    'CloseRequestFcn',@(s,e)PacmanCloseFcn);    % when figure is closed
myAxes1 = axes('Units','normalized','Position',[0.1 0.1 0.8 0.8],...                                            
    'XLim',[-3.11 32.01],'YLim',[-3.11 32.01]); 
hold(myAxes1,'on')
axis(myAxes1,'off','equal')

allDirections = gameData.gameData.allDirections;    % all possible Directions in each square
allSprites = gameData.gameData.allSprites;          % all sprites-data
allWalls = gameData.gameData.allWalls;              % all wall-data
ghostSprites = allSprites.ghosts;                   % all ghosts-Sprites
eyeSprites = allSprites.eyes;                       % all eyes-Sprites
grumpySprites = allSprites.grumpy;                  % all grumpy-Sprites
fruits.data = allSprites.fruits;                    % all fruits-Sprites

plot(myAxes1,allWalls.pacmanWalls(1,:),allWalls.pacmanWalls(2,:),'b-','LineWidth',2)    % plot all walls
plot(myAxes1,[13.1 15.9],[18.75 18.75],'w-','LineWidth',3)                              % plot gate of ghost cage

%% Coins 
coins = gameData.gameData.coins;    % all coins-data
coins.originalData = coins.data;    % remember that data for a new game
coins.plot = plot(coins.data(:,1),coins.data(:,2),'w.','MarkerSize',7); % plot all coins

imagesc(myAxes1,'XData',[0 0.001],'YData',[0.001 0],'CData',repmat(1:length(allSprites.colormap(:,1)),[length(allSprites.colormap(:,1)), 1]),'Visible','on');
colormap(allSprites.colormap)   % change colormap

%% Initialize Ghosts
enemies(1).pos = [14.5, 20];            % ghost position
enemies(1).dir = 0;                     % current ghost direction (right-1, down-2, left-3, up-4)
enemies(1).oldDir = 1;                  % last ghost direction
enemies(1).speed = overallEnemySpeed;   % ghost speed
enemies(1).status = 0;                  % ghost status (0-in cage, 1-normal, 2-grumpy, 3-eyes) 
% enemies(1).statusTimer = -1;            % remember time for status change
enemies(1).curPosMov = [1, 3];          % current squares's possible moves
enemies(1).plot = imagesc(myAxes1,'XData',[enemies(1).pos(1)-0.6 enemies(1).pos(1)+0.6],'YData',[enemies(1).pos(2)+0.6 enemies(1).pos(2)-0.6],'CData',ghostSprites{1,2,1});
enemies(1).text = text(enemies(1).pos(1),enemies(1).pos(2),'100','Color','w','FontSize',8,'Visible','off','Parent',myAxes1,'FontName',pacFont,'FontWeight','bold');
enemies(1).possibleMoves = 1;
% enemies(1).distance1 = 0;
enemies(1).x1 = 1;
enemies(1).y1 = 1;
enemies(1).x1a = 1;
enemies(1).y1a = 1;
Timer_on1 = 1 ;

% enemies(2).pos = [14.5, 20];
% enemies(2).dir = 0;
% enemies(2).oldDir = 1;
% enemies(2).speed = overallEnemySpeed;
% enemies(2).status = 0;
% % enemies(2).statusTimer = -1;
% enemies(2).curPosMov = 0;
% enemies(2).plot = imagesc(myAxes1,'XData',[enemies(2).pos(1)-0.6 enemies(2).pos(1)+0.6],'YData',[enemies(2).pos(2)+0.6 enemies(2).pos(2)-0.6],'CData',ghostSprites{2,2,1});
% enemies(2).text = text(enemies(2).pos(1),enemies(2).pos(2),'100','Color','w','FontSize',8,'Visible','off','Parent',myAxes1,'FontName',pacFont,'FontWeight','bold');
% enemies(2).possibleMoves = 1;
% % enemies(2).distance2 = 0;
% enemies(2).x1 = 1;
% enemies(2).y1 = 1;
% enemies(2).x1a = 1;
% enemies(2).y1a = 1;
Timer_on2 = 1 ; 

enemies(3).pos = [14.5, 20];
enemies(3).dir = 0;
enemies(3).oldDir = 1;
enemies(3).speed = overallEnemySpeed;
enemies(3).status = 1;
% enemies(3).statusTimer = -1;
enemies(3).curPosMov = [1, 3];
enemies(3).plot = imagesc(myAxes1,'XData',[enemies(3).pos(1)-0.6 enemies(3).pos(1)+0.6],'YData',[enemies(3).pos(2)+0.6 enemies(3).pos(2)-0.6],'CData',ghostSprites{3,2,1});
enemies(3).text = text(enemies(3).pos(1),enemies(3).pos(2),'100','Color','w','FontSize',8,'Visible','off','Parent',myAxes1,'FontName',pacFont,'FontWeight','bold');
enemies(3).possibleMoves = 1;
% enemies(3).distance3 = 0;
enemies(3).x1 = 1;
enemies(3).y1 = 1;
enemies(3).x1a = 1;
enemies(3).y1a = 1;
Timer_on3 = 1 ;

% enemies(4).pos = [16.5, 17.5];
% enemies(4).dir = 0;
% enemies(4).oldDir = 1;
% enemies(4).speed = overallEnemySpeed;
% enemies(4).status = 0;
% enemies(4).statusTimer = -1;
% enemies(4).curPosMov = 0;
% enemies(4).plot = imagesc(myAxes1,'XData',[enemies(4).pos(1)-0.6 enemies(4).pos(1)+0.6],'YData',[enemies(4).pos(2)+0.6 enemies(4).pos(2)-0.6],'CData',ghostSprites{4,2,1});
% enemies(4).text = text(enemies(4).pos(1),enemies(4).pos(2),'100','Color','w','FontSize',8,'Visible','off','Parent',myAxes1,'FontName',pacFont,'FontWeight','bold');
% enemies(4).possibleMoves = 1;
% % enemies(4).distance4 = 0;
% enemies(4).x1 = 1;
% enemies(4).y1 = 1;
% enemies(4).x1a = 1;
% enemies(4).y1a = 1;
Timer_on4 = 1 ;
%% Fruits
fruits.pos = [0, 0];    % fruit position
fruits.item = 1;        % current level's fruit
fruits.score = [100 100 200 200 300 300 400 500]; % scores for each fruit
fruits.picked = zeros(1,8); % how many time each fruit picked was up
fruits.timer = randi([300,1500],1); % time window when fruit will appear
fruits.scoreText = text(fruits.pos(1),fruits.pos(2),'100','Color','w','FontSize',8,'Visible','off','Parent',myAxes1,'FontName',pacFont,'FontWeight','bold');
fruits.plot = imagesc(myAxes1,'XData',[0 1],'YData',[1 0],'CData',fruits.data{fruits.item},'Visible','off','Parent',myAxes1);
fruits.bottomPlot = gobjects(1,8);
fruits.bottomText = gobjects(1,8);
for ii = 1:8
    fruits.bottomPlot(ii) = imagesc(myAxes1,'XData',[27 29]-(ii-1)*2.4,'YData',[-0.8 -2.8],'CData',fruits.data{ii},'Visible','off','Parent',myAxes1);
    fruits.bottomText(ii) = text(28-(ii-1)*2.4,-3.5,[num2str(0) 'x'],'Color','w','FontSize',12,'FontName',pacFont,'FontWeight','bold','HorizontalAlignment','center','Parent',myAxes1,'Visible','off');
end

ghostFrame = 1;             % make the ghosts wobble
grumpyColorChange = 0;      % determines grumpy host color (blue or white)
grumpyTimeSwitchSave = 0;   % this variable remembers the timer-status, so the grumpy-ghosts all change at the the same time (blue-white-blue-...)
ghostPoints = 100;           % determines how many points a ghost adds to the score (doubles with each kill)

%% Initialize pacman
pacman.size = 0.8;          % pacman size
pacman.pos = [22 5]; %[25 8];%[27 30];%[25 8];%[7 30];      % position of pacman
pacman.dir = 0;             % direction of pacman
pacman.oldDir = 1;          % old direction of pacman
pacman.status = -2;         % -2 is normal, -3 is hit by ghost (don't ask me why I chose 'em numbers like that)

% Calculate all pacman frames, from closed to fully open
for ii = 0:18
    pacman.frames{1,ii+1} = [[-0.3 sin(linspace(pi/2+ii*pi/18,5/2*pi-ii*pi/18,50))*pacman.size -0.3];[0 cos(linspace(pi/2+ii*pi/18,5/2*pi-ii*pi/18,50))*pacman.size 0]];
    pacman.frames{2,ii+1} = [[0 sin(linspace(pi/2+ii*pi/18+pi/2,5/2*pi-ii*pi/18+pi/2,50))*pacman.size 0];[0.3 cos(linspace(pi/2+ii*pi/18+pi/2,5/2*pi-ii*pi/18+pi/2,50))*pacman.size 0.3]];
    pacman.frames{3,ii+1} = [[0.3 sin(linspace(pi/2+ii*pi/18-pi,5/2*pi-ii*pi/18-pi,50))*pacman.size 0.3];[0 cos(linspace(pi/2+ii*pi/18-pi,5/2*pi-ii*pi/18-pi,50))*pacman.size 0]];
    pacman.frames{4,ii+1} = [[0 sin(linspace(pi/2+ii*pi/18-pi/2,5/2*pi-ii*pi/18-pi/2,50))*pacman.size 0];[-0.3 cos(linspace(pi/2+ii*pi/18-pi/2,5/2*pi-ii*pi/18-pi/2,50))*pacman.size -0.3]];
end

curFrame = 5;           % open-close-frame
frameDirection = 1;     % direction-frame
pacman.plot = fill(pacman.frames{pacman.oldDir,curFrame}(1,:)+pacman.pos(1),pacman.frames{pacman.oldDir,curFrame}(2,:)+pacman.pos(2),'y','Parent',myAxes1);

%% lives, score, level, info, animations...
lives.data = 3;         % lives of pacman
lives.plot = gobjects(1,3);
for ii = 1:lives.data
    lives.plot(ii) = fill(pacman.frames{1,5}(1,:)+1+3*(ii-1),pacman.frames{1,5}(2,:)-2,'y');
end

score.data = 0;         % score
score.plot = text(29,33.5,['Score: ' num2str(score.data)],'Color','w','FontSize',16,'HorizontalAlign','Right','FontName',pacFont,'FontWeight','bold');

level.data = 1;          	% level
level.plot = text(0,33.5,['Level: ' num2str(level.data)],'Color','w','FontSize',16,'HorizontalAlign','Left','FontName',pacFont,'FontWeight','bold');

info.text = text(14.65,13.9,'READY!','Color','g','FontSize',14,'FontWeight','bold','horizontalAlignment','center','FontName',pacFont,'FontWeight','bold');

rays.num = 12;          % bursting rays when pacman is hit by ghost
rays.numFrames = 20;
rays.t = linspace(0,2*pi*(1-1/rays.num),rays.num);
rays.rad1 = linspace(0,1,rays.numFrames);
rays.rad2 = linspace(0.5,1,rays.numFrames);
rays.plot = plot(0, 0,'y-','Visible','off');

%% Timer
myTimer = timer('TimerFcn',@(s,e)GameLoop,'Period',game.speed,'ExecutionMode','fixedRate');

%% UI-controls
newGameButton = uicontrol('Style','pushbutton',...
    'units','normalized',...
    'String','New Game',...
    'FontSize',16,...
    'ForegroundColor','k',...
    'Position',[0.38 0.81 0.24 0.05],...
    'Parent',pacman_Fig,...
    'Enable','off',...
    'ButtonDownFcn',@(s,e)newGameButtonFun);
createGhostsButton = uicontrol('Style','pushbutton',...
    'units','normalized',...
    'String','Create Ghosts',...
    'FontSize',16,...
    'ForegroundColor','k',...
    'Position',[0.38 0.75 0.24 0.05],...
    'Parent',pacman_Fig,...
    'Enable','off',...
    'ButtonDownFcn',@(s,e)createGhostsFun);
loadGhostsButton = uicontrol('Style','pushbutton',...
    'units','normalized',...
    'String','Load Ghosts',...
    'FontSize',16,...
    'ForegroundColor','k',...
    'Position',[0.38 0.69 0.24 0.05],...
    'Parent',pacman_Fig,...
    'Enable','off',...
    'ButtonDownFcn',@(s,e)loadGhostsFun);

%% Include Pacman Ghost Creator
% first an empty figure is created. The figure-parameters are then
% specified in "pacmanCreator.m".
pacmanGhostCreator_Fig = figure('Visible','off');

    function newGameButtonFun
        coins.data = coins.originalData;
        level.data = 1;
        score.data = 0;
        lives.data = 3;
        set(lives.plot(:),'Visible','on')
        set(fruits.bottomPlot(:),'Visible','off')
        set(newGameButton,'Visible','off')
        set(createGhostsButton,'Visible','off')
        set(loadGhostsButton,'Visible','off')
        set(pacmanGhostCreator_Fig,'Visible','off')
        
        newGame
        set(info.text,'Visible','off')
    end

    function createGhostsFun
        pacmanCreator(pacmanGhostCreator_Fig);
    end

    function loadGhostsFun
        [FileName,PathName,~] = uigetfile('*.mat');
        gameData = load(fullfile([PathName FileName]));
        allSprites = gameData.gameData.allSprites;
        ghostSprites = allSprites.ghosts;
        eyeSprites = allSprites.eyes;
        grumpySprites = allSprites.grumpy;
        colormap(allSprites.colormap)
        
        for nn = [1,3]
            plotGhost(enemies(nn),ghostSprites{nn,enemies(nn).oldDir,ghostFrame+1},zeros(14,14))
        end
    end

    function GameLoop
        pacmanMoveFun
        enemyRefresh
%         pillsFun
        fruitsFun
        coinsFun
    end

    function newGame
        
        stop(myTimer)
        enemies(1).pos = [14.5, 20];
%         enemies(2).pos = [14.5, 20];
        enemies(3).pos = [14.5, 20];
%         enemies(4).pos = [16.5, 17.5];
        for nn = 1
            enemies(nn).status = 0;
            enemies(nn).dir = 0;
            enemies(nn).oldDir = 2;
            enemies(nn).speed = overallEnemySpeed;
            enemies(nn).statusTimer = -1;
            enemies(nn).curPosMov = [1, 3];
            enemies(nn).possibleMoves = 1;
%             enemies(nn).distance = 10;
            enemies(nn).x1 = 1;
            enemies(nn).y1 = 1;
            enemies(nn).x1a = 1;
            enemies(nn).y1a = 1;
            
        end
        for nn = 3
            enemies(nn).status = 0;
            enemies(nn).dir = 0;
            enemies(nn).oldDir = 2;
            enemies(nn).speed = overallEnemySpeed;
            enemies(nn).statusTimer = -1;
            enemies(nn).curPosMov = [1, 3];
            enemies(nn).possibleMoves = 1;
%             enemies(nn).distance = 10;
            enemies(nn).x1 = 1;
            enemies(nn).y1 = 1;
            enemies(nn).x1a = 1;
            enemies(nn).y1a = 1;
            
        end
%         enemies(1).distance1 = 1;
%         enemies(2).distance2 = 1;
%         enemies(3).distance3 = 1;
%         enemies(4).distance4 = 1;
%         enemies(1).dir = 1;
        enemies(1).status = 1;
%         enemies(2).status = 1;
        enemies(3).status = 1;
        pacman.pos = [22 5];%[25 8];%[27 30];%[25 8]; %[7 30];
        pacman.dir = 0;
        pacman.oldDir = 1;
        pacman.status = -2;

        set(pacman.plot,'XData',pacman.frames{pacman.oldDir,curFrame}(1,:)+pacman.pos(1),'YData',pacman.frames{pacman.oldDir,curFrame}(2,:)+pacman.pos(2))
        set(info.text,'String','READY!','Color','g','Visible','on')
        
        for nn = [1,3]
            plotGhost(enemies(nn),ghostSprites{nn,enemies(nn).oldDir,ghostFrame+1},zeros(14,14))
            set(enemies(nn).plot,'Visible','on')
        end
        
        pause(1)
        set(info.text,'Visible','off')
        start(myTimer)
    end

    function coinsFun
        if any(ismember(coins.data,findSquare(pacman,pacman.oldDir),'rows'))
            coins.data(ismember(coins.data,findSquare(pacman,pacman.oldDir),'rows'),:) = [];
            score.data = score.data+1;
        end
        
        set(coins.plot,'XData',coins.data(:,1),'YData',coins.data(:,2))
        set(score.plot,'String',['Score: ' num2str(score.data)])
        
        if isempty(coins.data) % next Level
            level.data = level.data+1;
            set(level.plot,'String',['Level: ' num2str(level.data)]);
            game.speed = game.speed-0.002;
            if game.speed < 0.009   %  0.025
                game.speed = 0.009; %  0.025 (limit game speed, so screen has time to update itself)
            end
            stop(myTimer)
            set(myTimer,'Period',game.speed)
            coins.data = coins.originalData;
%             pills.data = pills.originalData;
            fruits.timer = randi([300,1500],1);
            newGame
        end
    end

    function fruitsFun
        if (fruits.timer > 0 && fruits.timer < myTimer.TasksExecuted) || (fruits.timer > 0 && length(coins.data(:,1)) <= 10)
            fruits.timer = -1;
            
            fruits.item = mod(level.data,9);
            
            if level.data > 8
                fruits.item = mod(level.data-8*floor(level.data/8),9)+(~mod(level.data-8*floor(level.data/8),9))*8;
            end
            
            fruits.pos = coins.originalData(randi([1 length(coins.originalData(:,1))],1),:);
            
            alphaMask = fruits.data{fruits.item};
            alphaMask(alphaMask~=1) = 0;
            alphaMask = ~alphaMask;
            set(fruits.plot,'Visible','on','XData',[fruits.pos(1)-0.6 fruits.pos(1)+0.6],'YData',[fruits.pos(2)+0.6 fruits.pos(2)-0.6],'CData',fruits.data{fruits.item},'AlphaData',alphaMask)
        end 
        if any(ismember(fruits.pos,findSquare(pacman,pacman.oldDir),'rows'))
            for mm = 0:30
                set(fruits.scoreText,'String',num2str(fruits.score(fruits.item)),'Position',[fruits.pos(1)-0.6,fruits.pos(2)+(mm)/30+0.6,0],'Visible','on')
                pause(0.02)
            end
            fruits.pos = [0,0];
            fruits.picked(fruits.item) = fruits.picked(fruits.item)+1;
            score.data = score.data+fruits.score(fruits.item);
            set(fruits.scoreText,'Visible','off')
            set(fruits.plot,'Visible','off')
            set(fruits.bottomPlot(fruits.item),'CData',fruits.data{fruits.item},'Visible','on')
            set(fruits.bottomText(fruits.item),'String',[num2str(fruits.picked(fruits.item)) 'x'],'Visible','on');
        end
    end

    function pacmanMoveFun
        
        % Tunnel logic
        if pacman.pos(1) > 28
            pacman.pos(1) = 1;
        elseif pacman.pos(1) < 1
            pacman.pos(1) = 28;
        end
        pacman = pathWayLogic(pacman,pacman.speed);
    
        if frameDirection   % if mouth is opening 
            curFrame = curFrame+1;
        else                % if mouth is closing
            curFrame = curFrame-1;
        end
        
        if curFrame == 1        % if mouth is fully closed
            frameDirection = 1;
        elseif curFrame == 7    % if mouth is fully open
            frameDirection = 0;
        end
        
        % update pacman plot
        set(pacman.plot,'XData',pacman.frames{pacman.oldDir,curFrame}(1,:)+pacman.pos(1),'YData',pacman.frames{pacman.oldDir,curFrame}(2,:)+pacman.pos(2))
        
        if pacman.status == -3 % if pacman is hit by ghost
            lives.data = lives.data-1;  % lose 1 life
            
            % start animation
            for nn = [1,3] % turn ghosts off
                set(enemies(nn).plot,'Visible','off')
            end
            
            for nn = 0:18 % make pacman disappear
                set(pacman.plot,'XData',pacman.frames{pacman.oldDir,nn+1}(1,:)+pacman.pos(1),'YData',pacman.frames{pacman.oldDir,nn+1}(2,:)+pacman.pos(2))
                pause(0.05)
            end
            
            switch pacman.oldDir % move bursting-center to correct position
                case 1
                    explodeCorrection = [-0.4 0];
                case 2
                    explodeCorrection = [0 0.4];
                case 3
                    explodeCorrection = [0.4 0];
                case 4
                    explodeCorrection = [0 -0.4];
            end
            
            for nn = 1:rays.numFrames   % make pacman burst
                circ1 = rays.rad1(nn)*[sin(rays.t); cos(rays.t)];
                circ2 = rays.rad2(nn)*[sin(rays.t); cos(rays.t)];

                rays.data = zeros(2,3*rays.num);

                for kk = 1:rays.num
                    rays.data(1,1+(kk-1)*3:3+(kk-1)*3) = pacman.pos(1)+[circ1(1,kk) circ2(1,kk) NaN]+explodeCorrection(1);
                    rays.data(2,1+(kk-1)*3:3+(kk-1)*3) = pacman.pos(2)+[circ1(2,kk) circ2(2,kk) NaN]+explodeCorrection(2);
                end
                set(rays.plot,'XData',rays.data(1,:),'YData',rays.data(2,:),'Visible','on')
                pause(0.05)
            end
            set(rays.plot,'Visible','off')
            
            if lives.data >= 0 % start anew
                set(lives.plot(lives.data+1),'Visible','off')
                newGame
            else % Game Over
                set(info.text,'Visible','on','String','Game Over', 'Color','r')
                stop(myTimer)
                set(newGameButton,'Visible','on')
                set(createGhostsButton,'Visible','on')
                set(loadGhostsButton,'Visible','on')
            end
        end
        
    end

    function enemyRefresh % handles status and appearance of all ghosts 
        
        if curFrame == 3 || curFrame == 7 % switch between frames for movement illusion
            ghostFrame = ~ghostFrame;
        end
        for nn = [1,3] % consider one ghost at a time
            % ghost hits pacman
            if enemies(nn).status == 1 && abs(pacman.pos(1)-enemies(nn).pos(1)) < 1.1 && abs(pacman.pos(2)-enemies(nn).pos(2)) < 1.1
                pacman.status = -3; % pacman dies
            end
            
            % pacman hits grumpy ghost -> ghost dies
            if enemies(nn).status == 2 && abs(pacman.pos(1)-enemies(nn).pos(1)) < 1.1 && abs(pacman.pos(2)-enemies(nn).pos(2)) < 1.1
                enemies(nn).status = 3;
                enemies(nn).speed = overallEnemySpeed*2;
                enemies(nn).statusTimer = myTimer.TasksExecuted;
                ghostPoints = ghostPoints*2;
                score.data = score.data+ghostPoints;
                for mm = 0:30
                    set(enemies(nn).text,'String',num2str(ghostPoints),'Position',[enemies(nn).pos(1)-0.6,enemies(nn).pos(2)+mm/30,0],'Visible','on')
                    pause(0.02)
                end
                set(enemies(nn).text,'Visible','off')
            end
            
            % ghost or grumpy ghost exits the cage after certain time
            if nn > 1 && newEnemyTime*(nn-1) == myTimer.TasksExecuted
                if enemies(nn).status == 4
                    enemies(nn).status = 6;
                else
                    enemies(nn).status = 5;
                end
            end
            
            switch enemies(nn).status % handle ghost status 1 to 7
                case {0,4} % inside cage
                    if enemies(nn).pos(2) >= 17.5
                        enemies(nn).dir = 2;
                    elseif enemies(nn).pos(2) <= 16.5
                        enemies(nn).dir = 4;
                    end
                    switch enemies(nn).dir
                        case 2
                            enemySpeed = [0 -overallEnemySpeed];
                            enemies(nn).oldDir = enemies(nn).dir;
                            enemies(nn).pos = enemies(nn).pos+enemySpeed;
                        case 4
                            enemySpeed = [0 overallEnemySpeed];
                            enemies(nn).oldDir = enemies(nn).dir;
                            enemies(nn).pos = enemies(nn).pos+enemySpeed;
                    end
                    
                case 1 % normal mode
                    if enemies(nn).dir > 0
                        enemies(nn).oldDir = enemies(nn).dir;
                    end
                    if ~any(allPossibleMoves(enemies(nn)) == enemies(nn).dir) || ~isequal(allPossibleMoves(enemies(nn)),enemies(nn).curPosMov)
                        curSquare11 = findSquare(enemies(1),enemies(1).dir);
%                         curSquare12 = findSquare(enemies(2),enemies(2).dir);
                        curSquare13 = findSquare(enemies(3),enemies(3).dir);
%                         curSquare14 = findSquare(enemies(4),enemies(4).dir);
                        curSquare2 = findSquare(pacman,pacman.dir);
                       
                        [enemies(1).dir] = shortestPath(curSquare11,curSquare2,enemies(1));
%                          [enemies(2).dir] = shortestPath2(curSquare12,curSquare2,enemies(2));
                          [enemies(3).dir] = shortestPath3(curSquare13,curSquare2,enemies(3));
%                            [enemies(4).dir] = shortestPath4(curSquare14,curSquare2,enemies(4));
%                         oldpossibleMoves = possibleMoves ; 
pacman.pos
                        enemies(nn) = pathWayLogic(enemies(nn),enemies(nn).speed);
                        enemies(nn).curPosMov = allPossibleMoves(enemies(nn));
                    else
                        enemies(nn) = pathWayLogic(enemies(nn),enemies(nn).speed);
                    end
                    
                case 2 % grumpy mode
                    if enemies(nn).dir > 0
                        enemies(nn).oldDir = enemies(nn).dir;
                    end
                    if ~any(allPossibleMoves(enemies(nn)) == enemies(nn).dir) || ~isequal(allPossibleMoves(enemies(nn)),enemies(nn).curPosMov)
                        curSquare1 = findSquare(enemies(nn),enemies(nn).dir);
                        curSquare2 = findSquare(pacman,pacman.dir);

                        [enemies(nn).dir] = shortestPath(curSquare1,curSquare2,enemies(nn));
                    end
                    enemies(nn) = pathWayLogic(enemies(nn),overallEnemySpeed*0.5);
                case 3 % eye mode
                    if enemies(nn).dir > 0
                        enemies(nn).oldDir = enemies(nn).dir;
                    end
                    if ~any(allPossibleMoves(enemies(nn)) == enemies(nn).dir) || ~isequal(allPossibleMoves(enemies(nn)),enemies(nn).curPosMov)
                        curSquare1 = findSquare(enemies(nn),enemies(nn).dir);
                        curSquare2 = [14.5, 20];

                        [enemies(nn).dir] = shortestPath(curSquare1,curSquare2,enemies(nn),possibleMoves);
                    end
                    enemies(nn) = pathWayLogic(enemies(nn),enemies(nn).speed*1);
                    if isequal(findSquare(enemies(nn),enemies(nn).dir),[14, 20]) || isequal(findSquare(enemies(nn),enemies(nn).dir),[15, 20])
                        enemies(nn).status = 7;
                        enemies(nn).pos = [14.5,20];
                        enemies(nn).dir = 2;
                    end
                case {5,6} % 5-inside cage on the way out normal mode, 6-inside cage on the way out grumpy mode
                    if enemies(nn).pos(1) < 14.5
                        enemies(nn).dir = 1;
                    elseif enemies(nn).pos(1) > 14.5
                        enemies(nn).dir = 3;
                    elseif enemies(nn).pos(2) < 19.75
                        enemies(nn).dir = 4;
                    elseif enemies(nn).pos(2) >= 19.75
                        if enemies(nn).status == 6
                            enemies(nn).status = 2;
                        else
                            enemies(nn).status = 1;
                        end
                    end
                    switch enemies(nn).dir
                        case 1
                            enemySpeed = [overallEnemySpeed 0];
                            enemies(nn).oldDir = enemies(nn).dir;
                            enemies(nn).pos = enemies(nn).pos+enemySpeed;
                        case 3
                            enemySpeed = [-overallEnemySpeed 0];
                            enemies(nn).oldDir = enemies(nn).dir;
                            enemies(nn).pos = enemies(nn).pos+enemySpeed;
                        case 4
                            enemySpeed = [0 overallEnemySpeed];
                            enemies(nn).oldDir = enemies(nn).dir;
                            enemies(nn).pos = enemies(nn).pos+enemySpeed;
                    end
                case 7 % on the way inside the cage
                    enemies(nn).dir = 2;
                    enemySpeed = [0 -overallEnemySpeed];
                    enemies(nn).oldDir = enemies(nn).dir;
                    enemies(nn).pos = enemies(nn).pos+enemySpeed;
                    if enemies(nn).pos(2) <= 16.5
                        enemies(nn).status = 5;
                    end
            end
            
            % ghost appearance depending on current ghost status
            if (enemies(nn).status == 2 || enemies(nn).status == 4 || enemies(nn).status == 6) && myTimer.TasksExecuted - enemies(nn).statusTimer < grumpyTime-grumpyTimeSwitch
                alphaMask = grumpySprites{1,ghostFrame+1}; % transparency
                plotGhost(enemies(nn),grumpySprites{1,ghostFrame+1},alphaMask)
            elseif (enemies(nn).status == 2 || enemies(nn).status == 4 || enemies(nn).status == 6) && myTimer.TasksExecuted - enemies(nn).statusTimer < grumpyTime
                % ghosts switch from blue to white every 10 frames
                if ~mod(myTimer.TasksExecuted,10) && grumpyTimeSwitchSave ~= myTimer.TasksExecuted
                    grumpyColorChange = ~grumpyColorChange;
                    grumpyTimeSwitchSave = myTimer.TasksExecuted; % remembers last color change
                end
                alphaMask = grumpySprites{grumpyColorChange+1,ghostFrame+1};
                plotGhost(enemies(nn),grumpySprites{grumpyColorChange+1,ghostFrame+1},alphaMask)
            elseif (enemies(nn).status == 3 || enemies(nn).status == 7) && myTimer.TasksExecuted - enemies(nn).statusTimer < grumpyTime-grumpyTimeSwitch
                alphaMask = eyeSprites{nn,enemies(nn).oldDir};
                plotGhost(enemies(nn),eyeSprites{nn,enemies(nn).oldDir},alphaMask)
            else
                enemies(nn).speed = overallEnemySpeed;
                alphaMask = ghostSprites{nn,enemies(nn).oldDir,ghostFrame+1};
                plotGhost(enemies(nn),ghostSprites{nn,enemies(nn).oldDir,ghostFrame+1},alphaMask)
            end
            % return from grumpy to normal
            if (enemies(nn).status == 2 && myTimer.TasksExecuted - enemies(nn).statusTimer >= grumpyTime) || (enemies(nn).status == 3 && myTimer.TasksExecuted - enemies(nn).statusTimer >= grumpyTime-grumpyTimeSwitch)
                enemies(nn).status = 1;
            end
            % Tunnel logic
            if enemies(nn).pos(1) > 28
                enemies(nn).pos(1) = 1;
            elseif enemies(nn).pos(1) < 1
                enemies(nn).pos(1) = 28;
            end
            % remember ghost movement possiblities, proportional to enemy
            % speed, so that he remebers only the last squares's
            % possibilities
            if ~mod(myTimer.TasksExecuted,1/enemies(nn).speed+1)
                enemies(nn).curPosMov = allPossibleMoves(enemies(nn));
            end
        end
        
    end

    function plotGhost(curGhost,curCData,curAlphaMask)
        curAlphaMask(curAlphaMask~=1) = 0;
        curAlphaMask = ~curAlphaMask;
        set(curGhost.plot,'XData',[curGhost.pos(1)-0.6 curGhost.pos(1)+0.6],...
                          'YData',[curGhost.pos(2)+0.6 curGhost.pos(2)-0.6],...
                          'CData',curCData,...
                          'AlphaData',curAlphaMask)
    end

    function curSquare = findSquare(entity,dir)
        if dir == 1 || dir == 4
            curSquare = [round(entity.pos(1)-0.45),round(entity.pos(2)-0.45)];
        else
            curSquare = [round(entity.pos(1)+0.45),round(entity.pos(2)+0.45)];
        end
    end

    function possibleMoves = allPossibleMoves(entity)
        curSquare = findSquare(entity,entity.dir);
        possibleMoves = allDirections{curSquare(1),curSquare(2)};
    end

%%
% simple -> simpler -> simplest -> my AI
function [nextMove1] = shortestPath(square1,square2,entity)
    possibleMoves = allDirections{square1(1),square1(2)};
    enemies(1).possibleMoves = possibleMoves;
    %         Test_pacman = square2
    x1 = abs(square1(1)-square2(1));
    y1 = abs(square1(2)-square2(2));
    enemies(1).x1 = x1;
    enemies(1).y1 = y1;
    %         distance = x1 + y1
    distance1 = x1 + y1 ;
    enemies(1).distance1 = distance1;
    x1a = (square1(1)-square2(1));
    y1a = (square1(2)-square2(2));
    enemies(1).x1a = x1a;
    enemies(1).y1a = y1a;

    %         if (x1a < 0)
    %             x1_negative = x1a
    %         end
    if x1 >= y1
        if x1a >= 0
            nextMove = 3;
        else
            nextMove = 1;
        end
    else
        if y1a >= 0
            nextMove = 2;
        else
            nextMove = 4;
        end
    end
    %Test_enemies_dir = enemies(1).dir;
% %% Start Timer
% %     Test_timer = Timer_on1
%         if (enemies(1).distance1 >= 10) && (Timer_on1==1) ;
%             tic ;
%             Timer_on1 = 0 ;
%         end
% %             d1=0;d2=0;d3=0;d4=0;d5=0;d6=0;d7=0;d8=0;d9=0;d10=0;d11=0;d12=0;d13=0;d14=0;d15=0;d16=0;d17=0;d18=0;d19=0;d20=0;d21=0;d22=0;d23=0;d24=0;  %     d = ones(3,1);
%         if (toc>=1) && (toc<2) ;
%         d1 = enemies(1).distance1;
%         save('out1.mat','d1');Timer_on1 = 0 ;
%         end
%         if (toc>=2) && (toc<3) ;
%         d2 = enemies(1).distance1;
%         save('outout2.mat','d2');Timer_on1 = 0 ;
%         end
%         if (toc>=3) && (toc<4) ;
%         d3 = enemies(1).distance1;
%         save('out3.mat','d3');Timer_on1 = 0 ;
%         end
%         if (toc>=4) && (toc<5) ;
%         d4 = enemies(1).distance1;
%         save('out4.mat','d4');Timer_on1 = 0 ;
%         end
%         if (toc>=5) && (toc<6) ;
%         d5 = enemies(1).distance1;
%         save('out5.mat','d5');Timer_on1 = 0 ;
%         end
%         if (toc>=6) && (toc<7) ;
%         d6 = enemies(1).distance1;
%         save('out6.mat','d6');Timer_on1 = 0 ;
%         end
%         if (toc>=7) && (toc<8) ;
%         d7 = enemies(1).distance1;
%         save('out7.mat','d7');Timer_on1 = 0 ;
%         end
%         if (toc>=8) && (toc<9) ;
%         d8 = enemies(1).distance1;
%         save('out8.mat','d8');Timer_on1 = 0 ;
%         end
%         if (toc>=9) && (toc<10) ;
%         d9 = enemies(1).distance1;
%         save('out9.mat','d9');Timer_on1 = 0 ;
%         end
%         if (toc>=10) && (toc<11) ;
%         d10 = enemies(1).distance1;
%         save('outout10.mat','d10');Timer_on1 = 0 ;
%         end
%         if (toc>=11) && (toc<12) ;
%         d11 = enemies(1).distance1;
%         save('out11.mat','d11');Timer_on1 = 0 ;
%         end
%         if (toc>=12) && (toc<13) ;
%         d12 = enemies(1).distance1;
%         save('out12.mat','d12');Timer_on1 = 0 ;
%         end
%         if (toc>=13) && (toc<14) ;
%         d13 = enemies(1).distance1;
%         save('out13.mat','d13');Timer_on1 = 0 ;
%         end
%         if (toc>=14) && (toc<15) ;
%         d14 = enemies(1).distance1;
%         save('out14.mat','d14');Timer_on1 = 0 ;
%         end
%         if (toc>=15) && (toc<16) ;
%         d15 = enemies(1).distance1;
%         save('out15.mat','d15');Timer_on1 = 0 ;
%         end
%         if (toc>=16) && (toc<17) ;
%         d16 = enemies(1).distance1;
%         save('out16.mat','d16');Timer_on1 = 0 ;
%         end
%         if (toc>=17) && (toc<18) ;
%         d17 = enemies(1).distance1;
%         save('out17.mat','d17');Timer_on1 = 0 ;
%         end
%         if (toc>=18) && (toc<19) ;
%         d18 = enemies(1).distance1;
%         save('out18.mat','d18');Timer_on1 = 0 ;
%         end
%         if (toc>=19) && (toc<20) ;
%         d19 = enemies(1).distance1;
%         save('out19.mat','d19');Timer_on1 = 0 ;
%         end
%         if (toc>=20) && (toc<21) ;
%         d20 = enemies(1).distance1;
%         save('out20.mat','d20');Timer_on1 = 0 ;
%         end
% %         elseif (toc>=21) && (toc<22) ;
% %         d21 = enemies(1).distance1
% %         save('o21.mat','d21')
% % %         end
% %         elseif (toc>=22) && (toc<23) ;
% %         d22 = enemies(1).distance1
% %         save('o22.mat','d22')
% % %         end
% %         elseif (toc>=23) && (toc<24) ;
% %         d23 = enemies(1).distance1
% %         save('o23.mat','d23')
% % %         end
% %         end
%         
%     if (enemies(1).distance1 < 3) && (Timer_on1==0) ;
%     Timer_1 = toc
%     %      t = timeseries(Timer_1)
%     for j = 1:60
%         if (Timer_1>j)
%             t(j) = j;
% %             distance1
%         end
%     end
% load('out1.mat','d1');
% load('outout2.mat','d2');
% load('out3.mat','d3');
% load('out4.mat','d4');
% load('out5.mat','d5');
% load('out6.mat','d6');
% load('out7.mat','d7');
% load('out8.mat','d8');
% load('out9.mat','d9');
% load('outout10.mat','d10');
% load('out11.mat','d11');
% load('out12.mat','d12');
% load('out13.mat','d13');
% load('out14.mat','d14');
% load('out15.mat','d15');
% load('out16.mat','d16');
% load('out17.mat','d17');
% load('out18.mat','d18');
% load('out19.mat','d19');
% load('out20.mat','d20');
% % load('out21.mat','d21')
% % load('out22.mat','d22')
% % load('out24.mat','d24')
%     dist_vec = [d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 d16 d17 d18 d19 d20] ;% d21 d22 d23 d24] ;
%     save('dist_vec1.mat','dist_vec');
%     flag = 1;
% %     stem(1:20,dist_vec); Discrete Real time-series plot
%     end
% 
% %% End Timer
    %% Sigmoid function -> Simulated Annealing, from High Temp(Random walk) to Low Temperature(Hill Climbing)
    % distance = randi([1,50],1,1) ;
    t = linspace(1,10^3,50);  % t inversely proportional to Temperature,
    %Therefore, Temperature Very Low-> Very High
    % n = numel(t)  %  number of iterations
    T_0 = 10^3;
    % for jj = 1:numel(distance)
    % for nn = 1:n
    Temperature = T_0*(0.9910)^t(distance1); % Temperature,Low->High % Arbitrary Max distance 50
    % end
    Temperature';
    % plot(1:nn,Temperature)

    % Temperature = 20 ;
    % del = linspace(-20,120,100);
    % k = numel(distance);
    sigmoid_function = (1 + exp(6*(distance1/Temperature)))^(-1) ;
    % sigmoid_function';
    % plot(1:i,sigmoid_function) % probability - y axis; k - x axis;
    count1 = 0 ;
    if (sigmoid_function <= 0.40);
        count1 = count1 + 1 ;
    end
    Ghost_Distance = distance1;
    Ghost_Temperature = Temperature;
    Pr_1st_Ghost = sigmoid_function
%     disp('Acceptance_Pr > 0.46')
    count1;
%% end Sigmoid function Max Distance = 40, Min Distance = 12;
if (count1 == 1)
%     flag10001 = 1
    corner = numel(possibleMoves);   
%% Node Selection Start : Completely avoids tunnel's nextMove 
     if any(corner==2) ;%&& numel(enemies(1).possibleMoves)==numel(enemies(1).possibleMoves);
        nextMove = enemies(1).oldDir;  
%      disp('tunnel')
%% Node Selection End
     else %any(corner > 1) ;%~any(possibleMoves==enemies(1).dir) && numel(enemies(1).possibleMoves)==numel(enemies(1).possibleMoves);
        %       nextMove = nextMove;
        %         msize = numel(possibleMoves) ;
        %         idx = randperm(msize) ;
        %         nextMove = possibleMoves(idx(1:1)) ;
        % ** write code  1->Right 3->Left 2->Down 4->Up
        total_possibleMoves = numel(possibleMoves) ;
        switch total_possibleMoves
%             case 1
%                 ~any(possibleMoves==nextMove) ;
%                 nextMove = possibleMoves ;  %Since numel(possibleMoves) is 1 
            case 2   % Movement based on abs distance and non abs distance
%                 disp('tunnel')
                if (x1 >= y1) && (x1a>=0) ;
                    tentative_nextMove = [3] ;
                    nextMove = intersect(tentative_nextMove,possibleMoves);
                elseif (x1 >= y1) && (x1a<=0) ;
                    tentative_nextMove = [1];
                    nextMove = intersect(tentative_nextMove,possibleMoves);
                elseif (y1 >= x1) && (y1a>=0) ;
                    tentative_nextMove = [2];
                    nextMove = intersect(tentative_nextMove,possibleMoves);
                else (y1 >= x1) && (y1a<=0) ;
                    tentative_nextMove = [4];
                    nextMove = intersect(tentative_nextMove,possibleMoves);
                end
                %            Number_nextMove = numel(nextMove) ;
                %            if (Number_nextMove > 1)
                %                if (nextMove == [1 3])
                %                    if (x1a >= 0)
                %                        nextMove = 3 ;
                %                    else
                %                        nextMove = 1 ;
                %                    end
                %                else (nextMove == [2 4])
                %                    if (y1a >= 0)
                %                        nextMove = 2 ;
                %                    else
                %                        nextMove = 4 ;
                %                    end
                %                end
                %            end
                if isempty(nextMove)  % possibleMoves does not match tentative nextMove
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove = [2] ;
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove = [4];
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove = [1];
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove = [3];
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    end
                end
                if isempty(nextMove)
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove = [4] ;
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove = [2];
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove = [3];
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove = [1];
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    end
                end
                flag100 = nextMove ;
            case 3   
                disp('T-junction')
                if x1 > y1 ;
                    if (x1a >= 0);
                        nextMove = 3;
                    else
                        nextMove = 1;
                    end
                    nextMove = intersect(possibleMoves,nextMove);
                    if isempty(nextMove)
                        if (y1a >= 0) ;
                            nextMove = 2;
                        else
                            nextMove = 4;
                        end
                    end
                else y1 > x1 ;
                    if (y1a >= 0);
                        nextMove = 2;
                    else
                        nextMove = 4;
                    end
                    nextMove = intersect(possibleMoves,nextMove);
                    if isempty(nextMove)
                        if (x1a >= 0) ;
                            nextMove = 3;
                        else
                            nextMove = 1;
                        end
                    end
                end
                Number_nextMove = numel(nextMove) ;
                if Number_nextMove > 1
                    if (nextMove == [1 3])
                        if (x1a >= 0)
                            nextMove = 3 ;
                        else
                            nextMove = 1 ;
                        end
                    else (nextMove == [2 4])
                        if (y1a >= 0)
                            nextMove = 2 ;
                        else
                            nextMove = 4 ;
                        end
                    end
                end
                %     if (nextMove==3) || (nextMove==1) ;
                %         tentative_nextMove = [1 3] ;
                %       if (any(possibleMoves==1));
                %         possibleMoves(possibleMoves == 1) = [];
                %       else (any(possibleMoves==3));
                %         possibleMoves(possibleMoves == 3) = [];
                %       end
                %         nextMove = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     else (nextMove==2) || (nextMove==4) ;
                %         tentative_nextMove = [2 4] ;
                %       if (any(possibleMoves==2));
                %         possibleMoves(possibleMoves == 2) = [];
                %       else (any(possibleMoves==4));
                %         possibleMoves(possibleMoves == 4) = [];
                %       end
                %         nextMove = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     end
%                 Test_case_3 = nextMove ;
        end    
    end
    nextMove1 = nextMove;
elseif (count1 == 0) ;% && (enemies(1).distance1 < 2);
%%
%     disp('Acceptance_Pr > 0.46')
    corner = numel(possibleMoves);   
    %% Node Selection Start : Completely avoids tunnel's nextMove
%     if any(corner==2) ;%&& numel(enemies(1).possibleMoves)==numel(enemies(1).possibleMoves);
%         nextMove = enemies(1).oldDir;
%         disp('tunnel')
    %% Node Selection End
%     else %any(corner > 1) ;%~any(possibleMoves==enemies(1).dir) && numel(enemies(1).possibleMoves)==numel(enemies(1).possibleMoves);
        %       nextMove = nextMove;
        %         msize = numel(possibleMoves) ;
        %         idx = randperm(msize) ;
        %         nextMove = possibleMoves(idx(1:1)) ;
        % ** write code  1->Right 3->Left 2->Down 4->Up
        total_possibleMoves = numel(possibleMoves) ;
        switch total_possibleMoves
%             case 1
%                 ~any(possibleMoves==nextMove) ;
%                 nextMove = possibleMoves ;  %Since numel(possibleMoves) is 1 
            case 2   % Movement based on abs distance and non abs distance
%                 disp('tunnel')
                if (x1 >= y1) && (x1a>=0) ;
                    tentative_nextMove = [3] ;
                    nextMove = intersect(tentative_nextMove,possibleMoves);
                elseif (x1 >= y1) && (x1a<=0) ;
                    tentative_nextMove = [1];
                    nextMove = intersect(tentative_nextMove,possibleMoves);
                elseif (y1 >= x1) && (y1a>=0) ;
                    tentative_nextMove = [2];
                    nextMove = intersect(tentative_nextMove,possibleMoves);
                else (y1 >= x1) && (y1a<=0) ;
                    tentative_nextMove = [4];
                    nextMove = intersect(tentative_nextMove,possibleMoves);
                end
                %            Number_nextMove = numel(nextMove) ;
                %            if (Number_nextMove > 1)
                %                if (nextMove == [1 3])
                %                    if (x1a >= 0)
                %                        nextMove = 3 ;
                %                    else
                %                        nextMove = 1 ;
                %                    end
                %                else (nextMove == [2 4])
                %                    if (y1a >= 0)
                %                        nextMove = 2 ;
                %                    else
                %                        nextMove = 4 ;
                %                    end
                %                end
                %            end
                if isempty(nextMove)  % possibleMoves does not match tentative nextMove
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove = [2] ;
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove = [4];
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove = [1];
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove = [3];
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    end
                end
                if isempty(nextMove)
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove = [4] ;
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove = [2];
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove = [3];
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove = [1];
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    end
                end
                flag100 = nextMove ;
            case 3   
%                 disp('T-junction')
                if x1 > y1 ;
                    if (x1a >= 0);
                        nextMove = 3;
                    else
                        nextMove = 1;
                    end
                    nextMove = intersect(possibleMoves,nextMove);
                    if isempty(nextMove)
                        if (y1a >= 0) ;
                            nextMove = 2;
                        else
                            nextMove = 4;
                        end
                    end
                else y1 > x1 ;
                    if (y1a >= 0);
                        nextMove = 2;
                    else
                        nextMove = 4;
                    end
                    nextMove = intersect(possibleMoves,nextMove);
                    if isempty(nextMove)
                        if (x1a >= 0) ;
                            nextMove = 3;
                        else
                            nextMove = 1;
                        end
                    end
                end
                Number_nextMove = numel(nextMove) ;
                if Number_nextMove > 1
                    if (nextMove == [1 3])
                        if (x1a >= 0)
                            nextMove = 3 ;
                        else
                            nextMove = 1 ;
                        end
                    else (nextMove == [2 4])
                        if (y1a >= 0)
                            nextMove = 2 ;
                        else
                            nextMove = 4 ;
                        end
                    end
                end
                %     if (nextMove==3) || (nextMove==1) ;
                %         tentative_nextMove = [1 3] ;
                %       if (any(possibleMoves==1));
                %         possibleMoves(possibleMoves == 1) = [];
                %       else (any(possibleMoves==3));
                %         possibleMoves(possibleMoves == 3) = [];
                %       end
                %         nextMove = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     else (nextMove==2) || (nextMove==4) ;
                %         tentative_nextMove = [2 4] ;
                %       if (any(possibleMoves==2));
                %         possibleMoves(possibleMoves == 2) = [];
                %       else (any(possibleMoves==4));
                %         possibleMoves(possibleMoves == 4) = [];
                %       end
                %         nextMove = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     end
%                 Test_case_3 = nextMove ;
%         end
    end
%%
    Pincer_Moves = [0 nextMove];
    idx = randi(length(Pincer_Moves)); % random index into x
%     nextMove1 = Pincer_Moves(idx);
    nextMove1 = nextMove;
    disp('Heat - High') 
end
end
%%
%%

% % simple -> simpler -> simplest -> my AI
%     function [nextMove2] = shortestPath2(square1,square2,entity)
%         possibleMoves = allDirections{square1(1),square1(2)};
%         enemies(2).possibleMoves = possibleMoves;
% %         Test_pacman = square2
%         x1 = abs(square1(1)-square2(1));
%         y1 = abs(square1(2)-square2(2));
%         enemies(2).x1 = x1;
%         enemies(2).y1 = y1;
% %         distance = x1 + y1
%         distance2 = x1 + y1 ;
%         enemies(2).distance2 = distance2;
%         x1a = (square1(1)-square2(1));
%         y1a = (square1(2)-square2(2));
%         enemies(2).x1a = x1a;
%         enemies(2).y1a = y1a;
% 
% %         if (x1a < 0)
% %             x1_negative = x1a  
% %         end 
%         if x1 >= y1
%             if x1a >= 0
%                 nextMove = 3;
%             else                
%                 nextMove = 1;
%             end
%         else
%             if y1a >= 0
%                 nextMove = 2;
%             else                
%                 nextMove = 4;
%             end
%         end
% %         Test_nextMove = nextMove;
% 
% %     Test_timer = Timer_on2
%     if (enemies(2).distance2 >= 10) && (Timer_on2==1) ;   % Start Timer
%         %     tic  ;
%         tic ;
%         Timer_on2=0 ; 
%     elseif (enemies(2).distance2 < 5) && (Timer_on2==0) ;
%         Timer_2 = toc
%         Timer_on2 = 1 ;
%     end                     % End Timer
    % %% Start Timer
% %     Test_timer = Timer_on1
%         if (enemies(1).distance1 >= 10) && (Timer_on1==1) ;
%             tic ;
%             Timer_on1 = 0 ;
%         end
% %             d1=0;d2=0;d3=0;d4=0;d5=0;d6=0;d7=0;d8=0;d9=0;d10=0;d11=0;d12=0;d13=0;d14=0;d15=0;d16=0;d17=0;d18=0;d19=0;d20=0;d21=0;d22=0;d23=0;d24=0;  %     d = ones(3,1);
%         if (toc>=1) && (toc<2) ;
%         d1 = enemies(1).distance1;
%         save('out1.mat','d1');Timer_on1 = 0 ;
%         end
%         if (toc>=2) && (toc<3) ;
%         d2 = enemies(1).distance1;
%         save('outout2.mat','d2');Timer_on1 = 0 ;
%         end
%         if (toc>=3) && (toc<4) ;
%         d3 = enemies(1).distance1;
%         save('out3.mat','d3');Timer_on1 = 0 ;
%         end
%         if (toc>=4) && (toc<5) ;
%         d4 = enemies(1).distance1;
%         save('out4.mat','d4');Timer_on1 = 0 ;
%         end
%         if (toc>=5) && (toc<6) ;
%         d5 = enemies(1).distance1;
%         save('out5.mat','d5');Timer_on1 = 0 ;
%         end
%         if (toc>=6) && (toc<7) ;
%         d6 = enemies(1).distance1;
%         save('out6.mat','d6');Timer_on1 = 0 ;
%         end
%         if (toc>=7) && (toc<8) ;
%         d7 = enemies(1).distance1;
%         save('out7.mat','d7');Timer_on1 = 0 ;
%         end
%         if (toc>=8) && (toc<9) ;
%         d8 = enemies(1).distance1;
%         save('out8.mat','d8');Timer_on1 = 0 ;
%         end
%         if (toc>=9) && (toc<10) ;
%         d9 = enemies(1).distance1;
%         save('out9.mat','d9');Timer_on1 = 0 ;
%         end
%         if (toc>=10) && (toc<11) ;
%         d10 = enemies(1).distance1;
%         save('outout10.mat','d10');Timer_on1 = 0 ;
%         end
%         if (toc>=11) && (toc<12) ;
%         d11 = enemies(1).distance1;
%         save('out11.mat','d11');Timer_on1 = 0 ;
%         end
%         if (toc>=12) && (toc<13) ;
%         d12 = enemies(1).distance1;
%         save('out12.mat','d12');Timer_on1 = 0 ;
%         end
%         if (toc>=13) && (toc<14) ;
%         d13 = enemies(1).distance1;
%         save('out13.mat','d13');Timer_on1 = 0 ;
%         end
%         if (toc>=14) && (toc<15) ;
%         d14 = enemies(1).distance1;
%         save('out14.mat','d14');Timer_on1 = 0 ;
%         end
%         if (toc>=15) && (toc<16) ;
%         d15 = enemies(1).distance1;
%         save('out15.mat','d15');Timer_on1 = 0 ;
%         end
%         if (toc>=16) && (toc<17) ;
%         d16 = enemies(1).distance1;
%         save('out16.mat','d16');Timer_on1 = 0 ;
%         end
%         if (toc>=17) && (toc<18) ;
%         d17 = enemies(1).distance1;
%         save('out17.mat','d17');Timer_on1 = 0 ;
%         end
%         if (toc>=18) && (toc<19) ;
%         d18 = enemies(1).distance1;
%         save('out18.mat','d18');Timer_on1 = 0 ;
%         end
%         if (toc>=19) && (toc<20) ;
%         d19 = enemies(1).distance1;
%         save('out19.mat','d19');Timer_on1 = 0 ;
%         end
%         if (toc>=20) && (toc<21) ;
%         d20 = enemies(1).distance1;
%         save('out20.mat','d20');Timer_on1 = 0 ;
%         end
% %         elseif (toc>=21) && (toc<22) ;
% %         d21 = enemies(1).distance1
% %         save('o21.mat','d21')
% % %         end
% %         elseif (toc>=22) && (toc<23) ;
% %         d22 = enemies(1).distance1
% %         save('o22.mat','d22')
% % %         end
% %         elseif (toc>=23) && (toc<24) ;
% %         d23 = enemies(1).distance1
% %         save('o23.mat','d23')
% % %         end
% %         end
%         
%     if (enemies(1).distance1 < 3) && (Timer_on1==0) ;
%     Timer_1 = toc
%     %      t = timeseries(Timer_1)
%     for j = 1:60
%         if (Timer_1>j)
%             t(j) = j;
% %             distance1
%         end
%     end
% load('out1.mat','d1');
% load('outout2.mat','d2');
% load('out3.mat','d3');
% load('out4.mat','d4');
% load('out5.mat','d5');
% load('out6.mat','d6');
% load('out7.mat','d7');
% load('out8.mat','d8');
% load('out9.mat','d9');
% load('outout10.mat','d10');
% load('out11.mat','d11');
% load('out12.mat','d12');
% load('out13.mat','d13');
% load('out14.mat','d14');
% load('out15.mat','d15');
% load('out16.mat','d16');
% load('out17.mat','d17');
% load('out18.mat','d18');
% load('out19.mat','d19');
% load('out20.mat','d20');
% % load('out21.mat','d21')
% % load('out22.mat','d22')
% % load('out24.mat','d24')
%     dist_vec = [d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 d16 d17 d18 d19 d20] ;% d21 d22 d23 d24] ;
%     save('dist_vec1.mat','dist_vec');
%     flag = 1;
% %     stem(1:20,dist_vec); Discrete Real time-series plot
%     end
% 
% %% End Timer
% 
%     %% Sigmoid function -> Simulated Annealing, from High Temp(Random walk) to Low Temperature(Hill Climbing)
%     % distance = randi([1,50],1,1) ;
%     t = linspace(1,10^3,50);  % t inversely proportional to Temperature,
%     %Therefore, Temperature Very Low-> Very High
%     % n = numel(t)  %  number of iterations
%     T_0 = 10^3;
%     % for jj = 1:numel(distance)
%     % for nn = 1:n
%     Temperature = T_0*(0.9910)^t(distance2); % Temperature,Low->High % Arbitrary Max distance 50
%     % end
%     Temperature';
%     % plot(1:nn,Temperature)
% 
%     % Temperature = 20 ;
%     % del = linspace(-20,120,100);
%     % k = numel(distance);
%     sigmoid_function = (1 + exp(6*(distance2/Temperature)))^(-1) ;
%     % sigmoid_function';
%     % plot(1:i,sigmoid_function) % probability - y axis; k - x axis;
%     count1 = 0 ;
%     if (sigmoid_function <= 0.38);
%         count1 = count1 + 1 ;
%     end
%     Ghost_Distance = distance2;
%     Ghost_Temperature = Temperature;
%     Pr_2nd_Ghost = sigmoid_function;
% %     disp('Acceptance_Pr > 0.46')
%     count1;
% %% end Sigmoid function Max Distance = 40, Min Distance = 12;
% if (count1 == 1)
% %     flag10001 = 1
%     corner = numel(possibleMoves);   
% %% Node Selection Start : Completely avoids tunnel's nextMove 
%      if any(corner==2) ;%&& numel(enemies(1).possibleMoves)==numel(enemies(1).possibleMoves);
%         nextMove = enemies(2).oldDir;  
%      disp('tunnel')
% %% Node Selection End
%      else %any(corner > 1) ;%~any(possibleMoves==enemies(1).dir) && numel(enemies(1).possibleMoves)==numel(enemies(1).possibleMoves);
%         %       nextMove = nextMove;
%         %         msize = numel(possibleMoves) ;
%         %         idx = randperm(msize) ;
%         %         nextMove = possibleMoves(idx(1:1)) ;
%         % ** write code  1->Right 3->Left 2->Down 4->Up
%         total_possibleMoves = numel(possibleMoves) ;
%         switch total_possibleMoves
%             case 1
%                 ~any(possibleMoves==nextMove) ;
%                 nextMove = possibleMoves ;  %Since numel(possibleMoves) is 1 
%             case 2   % Movement based on abs distance and non abs distance
%                 disp('tunnel')
%                 if (x1 >= y1) && (x1a>=0) ;
%                     tentative_nextMove = [3] ;
%                     nextMove = intersect(tentative_nextMove,possibleMoves);
%                 elseif (x1 >= y1) && (x1a<=0) ;
%                     tentative_nextMove = [1];
%                     nextMove = intersect(tentative_nextMove,possibleMoves);
%                 elseif (y1 >= x1) && (y1a>=0) ;
%                     tentative_nextMove = [2];
%                     nextMove = intersect(tentative_nextMove,possibleMoves);
%                 else (y1 >= x1) && (y1a<=0) ;
%                     tentative_nextMove = [4];
%                     nextMove = intersect(tentative_nextMove,possibleMoves);
%                 end
%                 %            Number_nextMove = numel(nextMove) ;
%                 %            if (Number_nextMove > 1)
%                 %                if (nextMove == [1 3])
%                 %                    if (x1a >= 0)
%                 %                        nextMove = 3 ;
%                 %                    else
%                 %                        nextMove = 1 ;
%                 %                    end
%                 %                else (nextMove == [2 4])
%                 %                    if (y1a >= 0)
%                 %                        nextMove = 2 ;
%                 %                    else
%                 %                        nextMove = 4 ;
%                 %                    end
%                 %                end
%                 %            end
%                 if isempty(nextMove)  % possibleMoves does not match tentative nextMove
%                     if (x1 >= y1) && (x1a>=0) ;
%                         tentative_nextMove = [2] ;
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     elseif (x1 >= y1) && (x1a<=0) ;
%                         tentative_nextMove = [4];
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     elseif (y1 >= x1) && (y1a>=0) ;
%                         tentative_nextMove = [1];
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     else (y1 >= x1) && (y1a<=0) ;
%                         tentative_nextMove = [3];
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     end
%                 end
%                 if isempty(nextMove)
%                     if (x1 >= y1) && (x1a>=0) ;
%                         tentative_nextMove = [4] ;
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     elseif (x1 >= y1) && (x1a<=0) ;
%                         tentative_nextMove = [2];
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     elseif (y1 >= x1) && (y1a>=0) ;
%                         tentative_nextMove = [3];
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     else (y1 >= x1) && (y1a<=0) ;
%                         tentative_nextMove = [1];
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     end
%                 end
%                 flag100 = nextMove ;
%             case 3   
%                 disp('T-junction')
%                 if x1 > y1 ;
%                     if (x1a >= 0);
%                         nextMove = 3;
%                     else
%                         nextMove = 1;
%                     end
%                     nextMove = intersect(possibleMoves,nextMove);
%                     if isempty(nextMove)
%                         if (y1a >= 0) ;
%                             nextMove = 2;
%                         else
%                             nextMove = 4;
%                         end
%                     end
%                 else y1 > x1 ;
%                     if (y1a >= 0);
%                         nextMove = 2;
%                     else
%                         nextMove = 4;
%                     end
%                     nextMove = intersect(possibleMoves,nextMove);
%                     if isempty(nextMove)
%                         if (x1a >= 0) ;
%                             nextMove = 3;
%                         else
%                             nextMove = 1;
%                         end
%                     end
%                 end
%                 Number_nextMove = numel(nextMove) ;
%                 if Number_nextMove > 1
%                     if (nextMove == [1 3])
%                         if (x1a >= 0)
%                             nextMove = 3 ;
%                         else
%                             nextMove = 1 ;
%                         end
%                     else (nextMove == [2 4])
%                         if (y1a >= 0)
%                             nextMove = 2 ;
%                         else
%                             nextMove = 4 ;
%                         end
%                     end
%                 end
%                 %     if (nextMove==3) || (nextMove==1) ;
%                 %         tentative_nextMove = [1 3] ;
%                 %       if (any(possibleMoves==1));
%                 %         possibleMoves(possibleMoves == 1) = [];
%                 %       else (any(possibleMoves==3));
%                 %         possibleMoves(possibleMoves == 3) = [];
%                 %       end
%                 %         nextMove = possibleMoves(randperm((length(possibleMoves)),1)) ;
%                 %     else (nextMove==2) || (nextMove==4) ;
%                 %         tentative_nextMove = [2 4] ;
%                 %       if (any(possibleMoves==2));
%                 %         possibleMoves(possibleMoves == 2) = [];
%                 %       else (any(possibleMoves==4));
%                 %         possibleMoves(possibleMoves == 4) = [];
%                 %       end
%                 %         nextMove = possibleMoves(randperm((length(possibleMoves)),1)) ;
%                 %     end
% %                 Test_case_3 = nextMove ;
%         end    
%     end
%     nextMove2 = nextMove;
% elseif (count1 == 0) ;% && (enemies(2).distance2 < 2);
% %%
% %     disp('Acceptance_Pr > 0.46')
%     corner = numel(possibleMoves);   
%     %% Node Selection Start : Completely avoids tunnel's nextMove
%     %      if any(corner==2) ;%&& numel(enemies(2).possibleMoves)==numel(enemies(2).possibleMoves);
%     %         nextMove = enemies(2).oldDir;
%     %      disp('tunnel')
%     %% Node Selection End
% %     else %any(corner > 1) ;%~any(possibleMoves==enemies(2).dir) && numel(enemies(2).possibleMoves)==numel(enemies(2).possibleMoves);
%         %       nextMove = nextMove;
%         %         msize = numel(possibleMoves) ;
%         %         idx = randperm(msize) ;
%         %         nextMove = possibleMoves(idx(1:1)) ;
%         % ** write code  1->Right 3->Left 2->Down 4->Up
%         total_possibleMoves = numel(possibleMoves) ;
%         switch total_possibleMoves
%             case 1
%                 ~any(possibleMoves==nextMove) ;
%                 nextMove = possibleMoves ;  %Since numel(possibleMoves) is 1 
%             case 2   % Movement based on abs distance and non abs distance
%                 disp('tunnel')
%                 if (x1 >= y1) && (x1a>=0) ;
%                     tentative_nextMove = [3] ;
%                     nextMove = intersect(tentative_nextMove,possibleMoves);
%                 elseif (x1 >= y1) && (x1a<=0) ;
%                     tentative_nextMove = [1];
%                     nextMove = intersect(tentative_nextMove,possibleMoves);
%                 elseif (y1 >= x1) && (y1a>=0) ;
%                     tentative_nextMove = [2];
%                     nextMove = intersect(tentative_nextMove,possibleMoves);
%                 else (y1 >= x1) && (y1a<=0) ;
%                     tentative_nextMove = [4];
%                     nextMove = intersect(tentative_nextMove,possibleMoves);
%                 end
%                 %            Number_nextMove = numel(nextMove) ;
%                 %            if (Number_nextMove > 1)
%                 %                if (nextMove == [1 3])
%                 %                    if (x1a >= 0)
%                 %                        nextMove = 3 ;
%                 %                    else
%                 %                        nextMove = 1 ;
%                 %                    end
%                 %                else (nextMove == [2 4])
%                 %                    if (y1a >= 0)
%                 %                        nextMove = 2 ;
%                 %                    else
%                 %                        nextMove = 4 ;
%                 %                    end
%                 %                end
%                 %            end
%                 if isempty(nextMove)  % possibleMoves does not match tentative nextMove
%                     if (x1 >= y1) && (x1a>=0) ;
%                         tentative_nextMove = [2] ;
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     elseif (x1 >= y1) && (x1a<=0) ;
%                         tentative_nextMove = [4];
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     elseif (y1 >= x1) && (y1a>=0) ;
%                         tentative_nextMove = [1];
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     else (y1 >= x1) && (y1a<=0) ;
%                         tentative_nextMove = [3];
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     end
%                 end
%                 if isempty(nextMove)
%                     if (x1 >= y1) && (x1a>=0) ;
%                         tentative_nextMove = [4] ;
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     elseif (x1 >= y1) && (x1a<=0) ;
%                         tentative_nextMove = [2];
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     elseif (y1 >= x1) && (y1a>=0) ;
%                         tentative_nextMove = [3];
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     else (y1 >= x1) && (y1a<=0) ;
%                         tentative_nextMove = [1];
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     end
%                 end
%                 flag100 = nextMove ;
%             case 3   
%                 disp('T-junction')
%                 if x1 > y1 ;
%                     if (x1a >= 0);
%                         nextMove = 3;
%                     else
%                         nextMove = 1;
%                     end
%                     nextMove = intersect(possibleMoves,nextMove);
%                     if isempty(nextMove)
%                         if (y1a >= 0) ;
%                             nextMove = 2;
%                         else
%                             nextMove = 4;
%                         end
%                     end
%                 else y1 > x1 ;
%                     if (y1a >= 0);
%                         nextMove = 2;
%                     else
%                         nextMove = 4;
%                     end
%                     nextMove = intersect(possibleMoves,nextMove);
%                     if isempty(nextMove)
%                         if (x1a >= 0) ;
%                             nextMove = 3;
%                         else
%                             nextMove = 1;
%                         end
%                     end
%                 end
%                 Number_nextMove = numel(nextMove) ;
%                 if Number_nextMove > 1
%                     if (nextMove == [1 3])
%                         if (x1a >= 0)
%                             nextMove = 3 ;
%                         else
%                             nextMove = 1 ;
%                         end
%                     else (nextMove == [2 4])
%                         if (y1a >= 0)
%                             nextMove = 2 ;
%                         else
%                             nextMove = 4 ;
%                         end
%                     end
%                 end
%                 %     if (nextMove==3) || (nextMove==1) ;
%                 %         tentative_nextMove = [1 3] ;
%                 %       if (any(possibleMoves==1));
%                 %         possibleMoves(possibleMoves == 1) = [];
%                 %       else (any(possibleMoves==3));
%                 %         possibleMoves(possibleMoves == 3) = [];
%                 %       end
%                 %         nextMove = possibleMoves(randperm((length(possibleMoves)),1)) ;
%                 %     else (nextMove==2) || (nextMove==4) ;
%                 %         tentative_nextMove = [2 4] ;
%                 %       if (any(possibleMoves==2));
%                 %         possibleMoves(possibleMoves == 2) = [];
%                 %       else (any(possibleMoves==4));
%                 %         possibleMoves(possibleMoves == 4) = [];
%                 %       end
%                 %         nextMove = possibleMoves(randperm((length(possibleMoves)),1)) ;
%                 %     end
% %                 Test_case_3 = nextMove ;
% %         end    
%     end
% %%
%     Pincer_Moves = [0 nextMove];
%     idx = randi(length(Pincer_Moves)); % random index into x
% %     nextMove2 = Pincer_Moves(idx);
%     nextMove2 = nextMove;
% %     disp('Pincer_Move - Attack or Blockade strategy') 
% end
% end
%%
%%
% simple -> simpler -> simplest -> my AI
    function [nextMove3] = shortestPath3(square1,square2,entity)
        possibleMoves = allDirections{square1(1),square1(2)};
        enemies(3).possibleMoves = possibleMoves;
%         Test_pacman = square2
        x1 = abs(square1(1)-square2(1));
        y1 = abs(square1(2)-square2(2));
        enemies(3).x1 = x1;
        enemies(3).y1 = y1;
%         distance = x1 + y1;
        distance3 = x1 + y1 ;
        enemies(3).distance3 = distance3;
        x1a = (square1(1)-square2(1));
        y1a = (square1(2)-square2(2));
        enemies(3).x1a = x1a;
        enemies(3).y1a = y1a;

%         if (x1a < 0)
%             x1_negative = x1a  
%         end 
        if x1 >= y1
            if x1a >= 0
                nextMove = 3;
            else                
                nextMove = 1;
            end
        else
            if y1a >= 0
                nextMove = 2;
            else                
                nextMove = 4;
            end
        end
%         Test_nextMove = nextMove;

%     Test_timer = Timer_on3
    if (enemies(3).distance3 >= 10) && (Timer_on3==1) ;   % Start Timer
        %     tic  ;
        tic ;
        Timer_on3=0 ; 
    elseif (enemies(3).distance3 < 5) && (Timer_on3==0) ;
        Timer_3 = toc
        Timer_on3 = 1 ;
    end                     % End Timer
    
    % %% Start Timer
% %     Test_timer = Timer_on1
%         if (enemies(1).distance1 >= 10) && (Timer_on1==1) ;
%             tic ;
%             Timer_on1 = 0 ;
%         end
% %             d1=0;d2=0;d3=0;d4=0;d5=0;d6=0;d7=0;d8=0;d9=0;d10=0;d11=0;d12=0;d13=0;d14=0;d15=0;d16=0;d17=0;d18=0;d19=0;d20=0;d21=0;d22=0;d23=0;d24=0;  %     d = ones(3,1);
%         if (toc>=1) && (toc<2) ;
%         d1 = enemies(1).distance1;
%         save('out1.mat','d1');Timer_on1 = 0 ;
%         end
%         if (toc>=2) && (toc<3) ;
%         d2 = enemies(1).distance1;
%         save('outout2.mat','d2');Timer_on1 = 0 ;
%         end
%         if (toc>=3) && (toc<4) ;
%         d3 = enemies(1).distance1;
%         save('out3.mat','d3');Timer_on1 = 0 ;
%         end
%         if (toc>=4) && (toc<5) ;
%         d4 = enemies(1).distance1;
%         save('out4.mat','d4');Timer_on1 = 0 ;
%         end
%         if (toc>=5) && (toc<6) ;
%         d5 = enemies(1).distance1;
%         save('out5.mat','d5');Timer_on1 = 0 ;
%         end
%         if (toc>=6) && (toc<7) ;
%         d6 = enemies(1).distance1;
%         save('out6.mat','d6');Timer_on1 = 0 ;
%         end
%         if (toc>=7) && (toc<8) ;
%         d7 = enemies(1).distance1;
%         save('out7.mat','d7');Timer_on1 = 0 ;
%         end
%         if (toc>=8) && (toc<9) ;
%         d8 = enemies(1).distance1;
%         save('out8.mat','d8');Timer_on1 = 0 ;
%         end
%         if (toc>=9) && (toc<10) ;
%         d9 = enemies(1).distance1;
%         save('out9.mat','d9');Timer_on1 = 0 ;
%         end
%         if (toc>=10) && (toc<11) ;
%         d10 = enemies(1).distance1;
%         save('outout10.mat','d10');Timer_on1 = 0 ;
%         end
%         if (toc>=11) && (toc<12) ;
%         d11 = enemies(1).distance1;
%         save('out11.mat','d11');Timer_on1 = 0 ;
%         end
%         if (toc>=12) && (toc<13) ;
%         d12 = enemies(1).distance1;
%         save('out12.mat','d12');Timer_on1 = 0 ;
%         end
%         if (toc>=13) && (toc<14) ;
%         d13 = enemies(1).distance1;
%         save('out13.mat','d13');Timer_on1 = 0 ;
%         end
%         if (toc>=14) && (toc<15) ;
%         d14 = enemies(1).distance1;
%         save('out14.mat','d14');Timer_on1 = 0 ;
%         end
%         if (toc>=15) && (toc<16) ;
%         d15 = enemies(1).distance1;
%         save('out15.mat','d15');Timer_on1 = 0 ;
%         end
%         if (toc>=16) && (toc<17) ;
%         d16 = enemies(1).distance1;
%         save('out16.mat','d16');Timer_on1 = 0 ;
%         end
%         if (toc>=17) && (toc<18) ;
%         d17 = enemies(1).distance1;
%         save('out17.mat','d17');Timer_on1 = 0 ;
%         end
%         if (toc>=18) && (toc<19) ;
%         d18 = enemies(1).distance1;
%         save('out18.mat','d18');Timer_on1 = 0 ;
%         end
%         if (toc>=19) && (toc<20) ;
%         d19 = enemies(1).distance1;
%         save('out19.mat','d19');Timer_on1 = 0 ;
%         end
%         if (toc>=20) && (toc<21) ;
%         d20 = enemies(1).distance1;
%         save('out20.mat','d20');Timer_on1 = 0 ;
%         end
% %         elseif (toc>=21) && (toc<22) ;
% %         d21 = enemies(1).distance1
% %         save('o21.mat','d21')
% % %         end
% %         elseif (toc>=22) && (toc<23) ;
% %         d22 = enemies(1).distance1
% %         save('o22.mat','d22')
% % %         end
% %         elseif (toc>=23) && (toc<24) ;
% %         d23 = enemies(1).distance1
% %         save('o23.mat','d23')
% % %         end
% %         end
%         
%     if (enemies(1).distance1 < 3) && (Timer_on1==0) ;
%     Timer_1 = toc
%     %      t = timeseries(Timer_1)
%     for j = 1:60
%         if (Timer_1>j)
%             t(j) = j;
% %             distance1
%         end
%     end
% load('out1.mat','d1');
% load('outout2.mat','d2');
% load('out3.mat','d3');
% load('out4.mat','d4');
% load('out5.mat','d5');
% load('out6.mat','d6');
% load('out7.mat','d7');
% load('out8.mat','d8');
% load('out9.mat','d9');
% load('outout10.mat','d10');
% load('out11.mat','d11');
% load('out12.mat','d12');
% load('out13.mat','d13');
% load('out14.mat','d14');
% load('out15.mat','d15');
% load('out16.mat','d16');
% load('out17.mat','d17');
% load('out18.mat','d18');
% load('out19.mat','d19');
% load('out20.mat','d20');
% % load('out21.mat','d21')
% % load('out22.mat','d22')
% % load('out24.mat','d24')
%     dist_vec = [d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 d16 d17 d18 d19 d20] ;% d21 d22 d23 d24] ;
%     save('dist_vec1.mat','dist_vec');
%     flag = 1;
% %     stem(1:20,dist_vec); Discrete Real time-series plot
%     end
% 
% %% End Timer
    %% Sigmoid function -> Simulated Annealing, from High Temp(Random walk) to Low Temperature(Hill Climbing)
    % distance = randi([1,50],1,1) ;
    t = linspace(1,10^3,50);  % t inversely proportional to Temperature,
    %Therefore, Temperature Very Low-> Very High
    % n = numel(t)  %  number of iterations
    T_0 = 10^3;
    % for jj = 1:numel(distance)
    % for nn = 1:n
    Temperature = T_0*(0.9910)^t(distance3); % Temperature,Low->High % Arbitrary Max distance 50
    % end
    Temperature';
    % plot(1:nn,Temperature)

    % Temperature = 20 ;
    % del = linspace(-20,120,100);
    % k = numel(distance);
    sigmoid_function = (1 + exp(6*(distance3/Temperature)))^(-1) ;
    % sigmoid_function';
    % plot(1:i,sigmoid_function) % probability - y axis; k - x axis;
    count1 = 0 ;
    if (sigmoid_function <= 0.48);
        count1 = count1 + 1 ;
    end
    Ghost_Distance = distance3;
    Ghost_Temperature = Temperature;
    Pr_3rd_Ghost = sigmoid_function
%     disp('Acceptance_Pr > 0.46')
    count1;
%% end Sigmoid function Max Distance = 40, Min Distance = 12;
if (count1 == 1)
%     flag10001 = 1
    corner = numel(possibleMoves);   
%% Node Selection Start : Completely avoids tunnel's nextMove 
     if any(corner==2) ;%&& numel(enemies(3).possibleMoves)==numel(enemies(3).possibleMoves);
        nextMove = enemies(3).oldDir;  
%      disp('tunnel')
%% Node Selection End
     else %any(corner > 1) ;%~any(possibleMoves==enemies(3).dir) && numel(enemies(3).possibleMoves)==numel(enemies(3).possibleMoves);
        %       nextMove = nextMove;
        %         msize = numel(possibleMoves) ;
        %         idx = randperm(msize) ;
        %         nextMove = possibleMoves(idx(1:1)) ;
        % ** write code  1->Right 3->Left 2->Down 4->Up
        total_possibleMoves = numel(possibleMoves) ;
        switch total_possibleMoves
%             case 1
%                 ~any(possibleMoves==nextMove) ;
%                 nextMove = possibleMoves ;  %Since numel(possibleMoves) is 1 
            case 2   % Movement based on abs distance and non abs distance
%                 disp('tunnel')
                if (x1 >= y1) && (x1a>=0) ;
                    tentative_nextMove = [3] ;
                    nextMove = intersect(tentative_nextMove,possibleMoves);
                elseif (x1 >= y1) && (x1a<=0) ;
                    tentative_nextMove = [1];
                    nextMove = intersect(tentative_nextMove,possibleMoves);
                elseif (y1 >= x1) && (y1a>=0) ;
                    tentative_nextMove = [2];
                    nextMove = intersect(tentative_nextMove,possibleMoves);
                else (y1 >= x1) && (y1a<=0) ;
                    tentative_nextMove = [4];
                    nextMove = intersect(tentative_nextMove,possibleMoves);
                end
                %            Number_nextMove = numel(nextMove) ;
                %            if (Number_nextMove > 1)
                %                if (nextMove == [1 3])
                %                    if (x1a >= 0)
                %                        nextMove = 3 ;
                %                    else
                %                        nextMove = 1 ;
                %                    end
                %                else (nextMove == [2 4])
                %                    if (y1a >= 0)
                %                        nextMove = 2 ;
                %                    else
                %                        nextMove = 4 ;
                %                    end
                %                end
                %            end
                if isempty(nextMove)  % possibleMoves does not match tentative nextMove
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove = [2] ;
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove = [4];
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove = [1];
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove = [3];
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    end
                end
                if isempty(nextMove)
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove = [4] ;
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove = [2];
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove = [3];
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove = [1];
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    end
                end
                flag100 = nextMove ;
            case 3   
%                 disp('T-junction')
                if x1 > y1 ;
                    if (x1a >= 0);
                        nextMove = 3;
                    else
                        nextMove = 1;
                    end
                    nextMove = intersect(possibleMoves,nextMove);
                    if isempty(nextMove)
                        if (y1a >= 0) ;
                            nextMove = 2;
                        else
                            nextMove = 4;
                        end
                    end
                else y1 > x1 ;
                    if (y1a >= 0);
                        nextMove = 2;
                    else
                        nextMove = 4;
                    end
                    nextMove = intersect(possibleMoves,nextMove);
                    if isempty(nextMove)
                        if (x1a >= 0) ;
                            nextMove = 3;
                        else
                            nextMove = 1;
                        end
                    end
                end
                Number_nextMove = numel(nextMove) ;
                if Number_nextMove > 1
                    if (nextMove == [1 3])
                        if (x1a >= 0)
                            nextMove = 3 ;
                        else
                            nextMove = 1 ;
                        end
                    else (nextMove == [2 4])
                        if (y1a >= 0)
                            nextMove = 2 ;
                        else
                            nextMove = 4 ;
                        end
                    end
                end
                %     if (nextMove==3) || (nextMove==1) ;
                %         tentative_nextMove = [1 3] ;
                %       if (any(possibleMoves==1));
                %         possibleMoves(possibleMoves == 1) = [];
                %       else (any(possibleMoves==3));
                %         possibleMoves(possibleMoves == 3) = [];
                %       end
                %         nextMove = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     else (nextMove==2) || (nextMove==4) ;
                %         tentative_nextMove = [2 4] ;
                %       if (any(possibleMoves==2));
                %         possibleMoves(possibleMoves == 2) = [];
                %       else (any(possibleMoves==4));
                %         possibleMoves(possibleMoves == 4) = [];
                %       end
                %         nextMove = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     end
%                 Test_case_3 = nextMove ;
        end    
    end
    nextMove3 = nextMove;
elseif (count1 == 0) ;% && (enemies(3).distance3 < 2);
%%
%     disp('Acceptance_Pr > 0.46')
    corner = numel(possibleMoves);   
    %% Node Selection Start : Completely avoids tunnel's nextMove
    %      if any(corner==2) ;%&& numel(enemies(3).possibleMoves)==numel(enemies(3).possibleMoves);
    %         nextMove = enemies(3).oldDir;
    %      disp('tunnel')
    %% Node Selection End
%     else %any(corner > 1) ;%~any(possibleMoves==enemies(3).dir) && numel(enemies(3).possibleMoves)==numel(enemies(3).possibleMoves);
        %       nextMove = nextMove;
        %         msize = numel(possibleMoves) ;
        %         idx = randperm(msize) ;
        %         nextMove = possibleMoves(idx(1:1)) ;
        % ** write code  1->Right 3->Left 2->Down 4->Up
        total_possibleMoves = numel(possibleMoves) ;
        switch total_possibleMoves
%             case 1
%                 ~any(possibleMoves==nextMove) ;
%                 nextMove = possibleMoves ;  %Since numel(possibleMoves) is 1 
            case 2   % Movement based on abs distance and non abs distance
%                 disp('tunnel')
                if (x1 >= y1) && (x1a>=0) ;
                    tentative_nextMove = [3] ;
                    nextMove = intersect(tentative_nextMove,possibleMoves);
                elseif (x1 >= y1) && (x1a<=0) ;
                    tentative_nextMove = [1];
                    nextMove = intersect(tentative_nextMove,possibleMoves);
                elseif (y1 >= x1) && (y1a>=0) ;
                    tentative_nextMove = [2];
                    nextMove = intersect(tentative_nextMove,possibleMoves);
                else (y1 >= x1) && (y1a<=0) ;
                    tentative_nextMove = [4];
                    nextMove = intersect(tentative_nextMove,possibleMoves);
                end
                %            Number_nextMove = numel(nextMove) ;
                %            if (Number_nextMove > 1)
                %                if (nextMove == [1 3])
                %                    if (x1a >= 0)
                %                        nextMove = 3 ;
                %                    else
                %                        nextMove = 1 ;
                %                    end
                %                else (nextMove == [2 4])
                %                    if (y1a >= 0)
                %                        nextMove = 2 ;
                %                    else
                %                        nextMove = 4 ;
                %                    end
                %                end
                %            end
                if isempty(nextMove)  % possibleMoves does not match tentative nextMove
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove = [2] ;
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove = [4];
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove = [1];
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove = [3];
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    end
                end
                if isempty(nextMove)
                    if (x1 >= y1) && (x1a>=0) ;
                        tentative_nextMove = [4] ;
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    elseif (x1 >= y1) && (x1a<=0) ;
                        tentative_nextMove = [2];
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    elseif (y1 >= x1) && (y1a>=0) ;
                        tentative_nextMove = [3];
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    else (y1 >= x1) && (y1a<=0) ;
                        tentative_nextMove = [1];
                        nextMove = intersect(tentative_nextMove,possibleMoves);
                    end
                end
                flag100 = nextMove ;
            case 3   
%                 disp('T-junction')
                if x1 > y1 ;
                    if (x1a >= 0);
                        nextMove = 3;
                    else
                        nextMove = 1;
                    end
                    nextMove = intersect(possibleMoves,nextMove);
                    if isempty(nextMove)
                        if (y1a >= 0) ;
                            nextMove = 2;
                        else
                            nextMove = 4;
                        end
                    end
                else y1 > x1 ;
                    if (y1a >= 0);
                        nextMove = 2;
                    else
                        nextMove = 4;
                    end
                    nextMove = intersect(possibleMoves,nextMove);
                    if isempty(nextMove)
                        if (x1a >= 0) ;
                            nextMove = 3;
                        else
                            nextMove = 1;
                        end
                    end
                end
                Number_nextMove = numel(nextMove) ;
                if Number_nextMove > 1
                    if (nextMove == [1 3])
                        if (x1a >= 0)
                            nextMove = 3 ;
                        else
                            nextMove = 1 ;
                        end
                    else (nextMove == [2 4])
                        if (y1a >= 0)
                            nextMove = 2 ;
                        else
                            nextMove = 4 ;
                        end
                    end
                end
                %     if (nextMove==3) || (nextMove==1) ;
                %         tentative_nextMove = [1 3] ;
                %       if (any(possibleMoves==1));
                %         possibleMoves(possibleMoves == 1) = [];
                %       else (any(possibleMoves==3));
                %         possibleMoves(possibleMoves == 3) = [];
                %       end
                %         nextMove = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     else (nextMove==2) || (nextMove==4) ;
                %         tentative_nextMove = [2 4] ;
                %       if (any(possibleMoves==2));
                %         possibleMoves(possibleMoves == 2) = [];
                %       else (any(possibleMoves==4));
                %         possibleMoves(possibleMoves == 4) = [];
                %       end
                %         nextMove = possibleMoves(randperm((length(possibleMoves)),1)) ;
                %     end
%                 Test_case_3 = nextMove ;
%         end    
    end
%%
    Pincer_Moves = [0 nextMove];
    idx = randi(length(Pincer_Moves)); % random index into x
%     nextMove3 = Pincer_Moves(idx);
    nextMove3 = nextMove;
    disp('Heat - High') 
end
end
%%
%%
% % simple -> simpler -> simplest -> my AI
%     function [nextMove4] = shortestPath4(square1,square2,entity)
%         possibleMoves = allDirections{square1(1),square1(2)};
%         enemies(4).possibleMoves = possibleMoves;
% %         Test_pacman = square2
%         x1 = abs(square1(1)-square2(1));
%         y1 = abs(square1(2)-square2(2));
%         enemies(4).x1 = x1;
%         enemies(4).y1 = y1;
% %         distance = x1 + y1;
%         distance4 = x1 + y1 ;
%         enemies(4).distance4 = distance4;
%         x1a = (square1(1)-square2(1));
%         y1a = (square1(2)-square2(2));
%         enemies(4).x1a = x1a;
%         enemies(4).y1a = y1a;
% 
% %         if (x1a < 0)
% %             x1_negative = x1a  
% %         end 
%         if x1 >= y1
%             if x1a >= 0
%                 nextMove = 3;
%             else                
%                 nextMove = 1;
%             end
%         else
%             if y1a >= 0
%                 nextMove = 2;
%             else                
%                 nextMove = 4;
%             end
%         end
% %         Test_nextMove = nextMove;
% 
% %     Test_timer = Timer_on3
%     if (enemies(4).distance4 >= 10) && (Timer_on4==1) ;   % Start Timer
%         %     tic  ;
%         tic ;
%         Timer_on4=0 ; 
%     elseif (enemies(4).distance4 < 5) && (Timer_on4==0) ;
%         Timer_4 = toc
%         Timer_on4 = 1 ;
%     end                     % End Timer
%      %% Sigmoid function -> Simulated Annealing, from High Temp(Random walk) to Low Temperature(Hill Climbing)
%     % distance = randi([1,50],1,1) ;
%     t = linspace(1,10^3,50);  % t inversely proportional to Temperature,
%     %Therefore, Temperature Very Low-> Very High
%     % n = numel(t)  %  number of iterations
%     T_0 = 10^3;
%     % for jj = 1:numel(distance)
%     % for nn = 1:n
%     Temperature = T_0*(0.9910)^t(distance4); % Temperature,Low->High % Arbitrary Max distance 50
%     % end
%     Temperature';
%     % plot(1:nn,Temperature)
% 
%     % Temperature = 20 ;
%     % del = linspace(-20,120,100);
%     % k = numel(distance);
%     sigmoid_function = (1 + exp(6*(distance4/Temperature)))^(-1) ;
%     % sigmoid_function';
%     % plot(1:i,sigmoid_function) % probability - y axis; k - x axis;
%     count1 = 0 ;
%     if (sigmoid_function <= 0.46);
%         count1 = count1 + 1 ;
%     end
%     Ghost_Distance = distance4;
%     Ghost_Temperature = Temperature
%     Pr = sigmoid_function;
% %     disp('Acceptance_Pr > 0.46')
%     count1;
% %% end Sigmoid function Max Distance = 40, Min Distance = 12;
% if (count1 == 1)
% %     flag10001 = 1
%     corner = numel(possibleMoves);   
% %% Node Selection Start : Completely avoids tunnel's nextMove 
%      if any(corner==2) ;%&& numel(enemies(4).possibleMoves)==numel(enemies(4).possibleMoves);
%         nextMove = enemies(4).oldDir;  
%      disp('tunnel')
% %% Node Selection End
%      else %any(corner > 1) ;%~any(possibleMoves==enemies(4).dir) && numel(enemies(4).possibleMoves)==numel(enemies(4).possibleMoves);
%         %       nextMove = nextMove;
%         %         msize = numel(possibleMoves) ;
%         %         idx = randperm(msize) ;
%         %         nextMove = possibleMoves(idx(1:1)) ;
%         % ** write code  1->Right 3->Left 2->Down 4->Up
%         total_possibleMoves = numel(possibleMoves) ;
%         switch total_possibleMoves
%             case 1
%                 ~any(possibleMoves==nextMove) ;
%                 nextMove = possibleMoves ;  %Since numel(possibleMoves) is 1 
%             case 2   % Movement based on abs distance and non abs distance
%                 disp('tunnel')
%                 if (x1 >= y1) && (x1a>=0) ;
%                     tentative_nextMove = [3] ;
%                     nextMove = intersect(tentative_nextMove,possibleMoves);
%                 elseif (x1 >= y1) && (x1a<=0) ;
%                     tentative_nextMove = [1];
%                     nextMove = intersect(tentative_nextMove,possibleMoves);
%                 elseif (y1 >= x1) && (y1a>=0) ;
%                     tentative_nextMove = [2];
%                     nextMove = intersect(tentative_nextMove,possibleMoves);
%                 else (y1 >= x1) && (y1a<=0) ;
%                     tentative_nextMove = [4];
%                     nextMove = intersect(tentative_nextMove,possibleMoves);
%                 end
%                 %            Number_nextMove = numel(nextMove) ;
%                 %            if (Number_nextMove > 1)
%                 %                if (nextMove == [1 3])
%                 %                    if (x1a >= 0)
%                 %                        nextMove = 3 ;
%                 %                    else
%                 %                        nextMove = 1 ;
%                 %                    end
%                 %                else (nextMove == [2 4])
%                 %                    if (y1a >= 0)
%                 %                        nextMove = 2 ;
%                 %                    else
%                 %                        nextMove = 4 ;
%                 %                    end
%                 %                end
%                 %            end
%                 if isempty(nextMove)  % possibleMoves does not match tentative nextMove
%                     if (x1 >= y1) && (x1a>=0) ;
%                         tentative_nextMove = [2] ;
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     elseif (x1 >= y1) && (x1a<=0) ;
%                         tentative_nextMove = [4];
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     elseif (y1 >= x1) && (y1a>=0) ;
%                         tentative_nextMove = [1];
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     else (y1 >= x1) && (y1a<=0) ;
%                         tentative_nextMove = [3];
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     end
%                 end
%                 if isempty(nextMove)
%                     if (x1 >= y1) && (x1a>=0) ;
%                         tentative_nextMove = [4] ;
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     elseif (x1 >= y1) && (x1a<=0) ;
%                         tentative_nextMove = [2];
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     elseif (y1 >= x1) && (y1a>=0) ;
%                         tentative_nextMove = [3];
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     else (y1 >= x1) && (y1a<=0) ;
%                         tentative_nextMove = [1];
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     end
%                 end
%                 flag100 = nextMove ;
%             case 3   
%                 disp('T-junction')
%                 if x1 > y1 ;
%                     if (x1a >= 0);
%                         nextMove = 3;
%                     else
%                         nextMove = 1;
%                     end
%                     nextMove = intersect(possibleMoves,nextMove);
%                     if isempty(nextMove)
%                         if (y1a >= 0) ;
%                             nextMove = 2;
%                         else
%                             nextMove = 4;
%                         end
%                     end
%                 else y1 > x1 ;
%                     if (y1a >= 0);
%                         nextMove = 2;
%                     else
%                         nextMove = 4;
%                     end
%                     nextMove = intersect(possibleMoves,nextMove);
%                     if isempty(nextMove)
%                         if (x1a >= 0) ;
%                             nextMove = 3;
%                         else
%                             nextMove = 1;
%                         end
%                     end
%                 end
%                 Number_nextMove = numel(nextMove) ;
%                 if Number_nextMove > 1
%                     if (nextMove == [1 3])
%                         if (x1a >= 0)
%                             nextMove = 3 ;
%                         else
%                             nextMove = 1 ;
%                         end
%                     else (nextMove == [2 4])
%                         if (y1a >= 0)
%                             nextMove = 2 ;
%                         else
%                             nextMove = 4 ;
%                         end
%                     end
%                 end
%                 %     if (nextMove==3) || (nextMove==1) ;
%                 %         tentative_nextMove = [1 3] ;
%                 %       if (any(possibleMoves==1));
%                 %         possibleMoves(possibleMoves == 1) = [];
%                 %       else (any(possibleMoves==3));
%                 %         possibleMoves(possibleMoves == 3) = [];
%                 %       end
%                 %         nextMove = possibleMoves(randperm((length(possibleMoves)),1)) ;
%                 %     else (nextMove==2) || (nextMove==4) ;
%                 %         tentative_nextMove = [2 4] ;
%                 %       if (any(possibleMoves==2));
%                 %         possibleMoves(possibleMoves == 2) = [];
%                 %       else (any(possibleMoves==4));
%                 %         possibleMoves(possibleMoves == 4) = [];
%                 %       end
%                 %         nextMove = possibleMoves(randperm((length(possibleMoves)),1)) ;
%                 %     end
% %                 Test_case_3 = nextMove ;
%         end    
%     end
%     nextMove4 = nextMove;
% elseif (count1 == 0) ;% && (enemies(4).distance4 < 2);
% %%
% %     disp('Acceptance_Pr > 0.46')
%     corner = numel(possibleMoves);   
%     %% Node Selection Start : Completely avoids tunnel's nextMove
%     %      if any(corner==2) ;%&& numel(enemies(4).possibleMoves)==numel(enemies(4).possibleMoves);
%     %         nextMove = enemies(4).oldDir;
%     %      disp('tunnel')
%     %% Node Selection End
% %     else %any(corner > 1) ;%~any(possibleMoves==enemies(4).dir) && numel(enemies(4).possibleMoves)==numel(enemies(4).possibleMoves);
%         %       nextMove = nextMove;
%         %         msize = numel(possibleMoves) ;
%         %         idx = randperm(msize) ;
%         %         nextMove = possibleMoves(idx(4:1)) ;
%         % ** write code  1->Right 3->Left 2->Down 4->Up
%         total_possibleMoves = numel(possibleMoves) ;
%         switch total_possibleMoves
%             case 1
%                 ~any(possibleMoves==nextMove) ;
%                 nextMove = possibleMoves ;  %Since numel(possibleMoves) is 1 
%             case 2   % Movement based on abs distance and non abs distance
%                 disp('tunnel')
%                 if (x1 >= y1) && (x1a>=0) ;
%                     tentative_nextMove = [3] ;
%                     nextMove = intersect(tentative_nextMove,possibleMoves);
%                 elseif (x1 >= y1) && (x1a<=0) ;
%                     tentative_nextMove = [1];
%                     nextMove = intersect(tentative_nextMove,possibleMoves);
%                 elseif (y1 >= x1) && (y1a>=0) ;
%                     tentative_nextMove = [2];
%                     nextMove = intersect(tentative_nextMove,possibleMoves);
%                 else (y1 >= x1) && (y1a<=0) ;
%                     tentative_nextMove = [4];
%                     nextMove = intersect(tentative_nextMove,possibleMoves);
%                 end
%                 %            Number_nextMove = numel(nextMove) ;
%                 %            if (Number_nextMove > 1)
%                 %                if (nextMove == [1 3])
%                 %                    if (x1a >= 0)
%                 %                        nextMove = 3 ;
%                 %                    else
%                 %                        nextMove = 1 ;
%                 %                    end
%                 %                else (nextMove == [2 4])
%                 %                    if (y1a >= 0)
%                 %                        nextMove = 2 ;
%                 %                    else
%                 %                        nextMove = 4 ;
%                 %                    end
%                 %                end
%                 %            end
%                 if isempty(nextMove)  % possibleMoves does not match tentative nextMove
%                     if (x1 >= y1) && (x1a>=0) ;
%                         tentative_nextMove = [2] ;
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     elseif (x1 >= y1) && (x1a<=0) ;
%                         tentative_nextMove = [4];
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     elseif (y1 >= x1) && (y1a>=0) ;
%                         tentative_nextMove = [1];
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     else (y1 >= x1) && (y1a<=0) ;
%                         tentative_nextMove = [3];
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     end
%                 end
%                 if isempty(nextMove)
%                     if (x1 >= y1) && (x1a>=0) ;
%                         tentative_nextMove = [4] ;
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     elseif (x1 >= y1) && (x1a<=0) ;
%                         tentative_nextMove = [2];
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     elseif (y1 >= x1) && (y1a>=0) ;
%                         tentative_nextMove = [3];
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     else (y1 >= x1) && (y1a<=0) ;
%                         tentative_nextMove = [1];
%                         nextMove = intersect(tentative_nextMove,possibleMoves);
%                     end
%                 end
%                 flag100 = nextMove ;
%             case 3   
%                 disp('T-junction')
%                 if x1 > y1 ;
%                     if (x1a >= 0);
%                         nextMove = 3;
%                     else
%                         nextMove = 1;
%                     end
%                     nextMove = intersect(possibleMoves,nextMove);
%                     if isempty(nextMove)
%                         if (y1a >= 0) ;
%                             nextMove = 2;
%                         else
%                             nextMove = 4;
%                         end
%                     end
%                 else y1 > x1 ;
%                     if (y1a >= 0);
%                         nextMove = 2;
%                     else
%                         nextMove = 4;
%                     end
%                     nextMove = intersect(possibleMoves,nextMove);
%                     if isempty(nextMove)
%                         if (x1a >= 0) ;
%                             nextMove = 3;
%                         else
%                             nextMove = 1;
%                         end
%                     end
%                 end
%                 Number_nextMove = numel(nextMove) ;
%                 if Number_nextMove > 1
%                     if (nextMove == [1 3])
%                         if (x1a >= 0)
%                             nextMove = 3 ;
%                         else
%                             nextMove = 1 ;
%                         end
%                     else (nextMove == [2 4])
%                         if (y1a >= 0)
%                             nextMove = 2 ;
%                         else
%                             nextMove = 4 ;
%                         end
%                     end
%                 end
%                 %     if (nextMove==3) || (nextMove==1) ;
%                 %         tentative_nextMove = [1 3] ;
%                 %       if (any(possibleMoves==1));
%                 %         possibleMoves(possibleMoves == 1) = [];
%                 %       else (any(possibleMoves==3));
%                 %         possibleMoves(possibleMoves == 3) = [];
%                 %       end
%                 %         nextMove = possibleMoves(randperm((length(possibleMoves)),1)) ;
%                 %     else (nextMove==2) || (nextMove==4) ;
%                 %         tentative_nextMove = [2 4] ;
%                 %       if (any(possibleMoves==2));
%                 %         possibleMoves(possibleMoves == 2) = [];
%                 %       else (any(possibleMoves==4));
%                 %         possibleMoves(possibleMoves == 4) = [];
%                 %       end
%                 %         nextMove = possibleMoves(randperm((length(possibleMoves)),1)) ;
%                 %     end
% %                 Test_case_3 = nextMove ;
% %         end    
%     end
% %%
%     Pincer_Moves = [0 nextMove];
%     idx = randi(length(Pincer_Moves)); % random index into x
% %     nextMove4 = Pincer_Moves(idx);
%     nextMove4 = nextMove;
% %     disp('Pincer_Move - Attack or Blockade strategy') 
% end
% end
%%
%%
%%

    function entity = pathWayLogic(entity,speed)
        possibleDirections_minus = allDirections{round(entity.pos(1)-0.45),round(entity.pos(2)-0.45)};
        possibleDirections_plus = allDirections{round(entity.pos(1)+0.45),round(entity.pos(2)+0.45)};
        
        switch entity.dir
            case 0
                entity.oldDir = 1;
            case 1
                if rem(round(entity.pos(2)/speed)*speed,1) == 0 && any(possibleDirections_minus==entity.dir)
                    entity.pos(2) = round(entity.pos(2)/speed)*speed;
                    entity.pos(1) = entity.pos(1)+speed;
                    entity.oldDir = 1;
                elseif entity.oldDir == 2 && any(possibleDirections_plus==entity.oldDir)
                    entity.pos(2) = entity.pos(2)-speed;
                elseif entity.oldDir == 4 && any(possibleDirections_minus==entity.oldDir)
                    entity.pos(2) = entity.pos(2)+speed;
                elseif entity.status > -2
                    entity.pos(2) = entity.pos(2)+speed;
                end
            case 2
                if rem(round(entity.pos(1)/speed)*speed,1) == 0 && any(possibleDirections_plus==entity.dir)
                    entity.pos(1) = round(entity.pos(1)/speed)*speed;
                    entity.pos(2) = entity.pos(2)-speed;
                    entity.oldDir = 2;
                elseif entity.oldDir == 1 && any(possibleDirections_minus==entity.oldDir)
                    entity.pos(1) = entity.pos(1)+speed;
                elseif entity.oldDir == 3 && any(possibleDirections_plus==entity.oldDir)
                    entity.pos(1) = entity.pos(1)-speed;
                elseif entity.status > -2
                    entity.pos(1) = entity.pos(1)-speed;
                end
            case 3
                if rem(round(entity.pos(2)/speed)*speed,1) == 0 && any(possibleDirections_plus==entity.dir)
                    entity.pos(2) = round(entity.pos(2)/speed)*speed;
                    entity.pos(1) = entity.pos(1)-speed;
                    entity.oldDir = 3;
                elseif entity.oldDir == 2 && any(possibleDirections_plus==entity.oldDir)
                    entity.pos(2) = entity.pos(2)-speed;
                elseif entity.oldDir == 4 && any(possibleDirections_minus==entity.oldDir)
                    entity.pos(2) = entity.pos(2)+speed;
                elseif entity.status > -2
                    entity.pos(2) = entity.pos(2)+speed;
                end
            case 4
                if rem(round(entity.pos(1)/speed)*speed,1) == 0 && any(possibleDirections_minus==entity.dir)
                    entity.pos(1) = round(entity.pos(1)/speed)*speed;
                    entity.pos(2) = entity.pos(2)+speed;
                    entity.oldDir = 4;
                elseif entity.oldDir == 1 && any(possibleDirections_minus==entity.oldDir)
                    entity.pos(1) = entity.pos(1)+speed;
                elseif entity.oldDir == 3 && any(possibleDirections_plus==entity.oldDir)
                    entity.pos(1) = entity.pos(1)-speed;
                elseif entity.status > -2
                    entity.pos(1) = entity.pos(1)-speed;
                end
        end
    end
    
    function KeyAction(~,evt)
%         animegraph13
        if strcmp(get(newGameButton,'Visible'),'on')
            newGameButtonFun
        end
        if pacman.dir > 0
            pacman.oldDir = pacman.dir;
        end
        switch evt.Key
            case {'d','rightarrow'}
                pacman.dir = 1;
            case {'s','downarrow'}
                pacman.dir = 2;
            case {'a','leftarrow'}
                pacman.dir = 3;
            case {'w','uparrow'}
                pacman.dir = 4;
        end
%         animegraph13
    end

%% Simulated Annealing Demo - Temperature and its corresponding Sig Func
distance_x = 1:45 ;
% distance_x = fliplr(distance_x) ;
tt = linspace(1,10^3,distance_x(end));  % t inversely proportional to Temperature, Therefore, Temperature Very Low-> Very High
h = numel(tt) ; %  number of iterations
T_01 = 10^3;
% for jj = 1:numel(distance)
for nnn = 1:h ;
Temperature_x(nnn) = T_01*(0.9910)^tt(nnn); % Temperature,Low->High % Arbitrary Max distance 50
end
% Test_Temperature = Temperature_x' ;
figure
subplot(2,1,1)       % add first plot in 2 x 1 grid
plot(1:nnn,Temperature_x,'b','linewidth',3)
title('Monotonically Decreasing Temperature Function')
ylabel('Temperature')
xlabel('Distance')
grid on
% T = 20 ;   
% del = linspace(-20,120,100);   
kkk = numel(distance_x);
for ii = 1:kkk;
    sigmoid_function_x(ii) = (1 + exp(06*(distance_x(ii)/Temperature_x(ii))))^(-1);
%  Temperature_x(ii)
end
% sigmoid_function';
hold on;
threshold = 0.46 * ones(1,length(distance_x)); 
subplot(2,1,2)       % add second plot in 2 x 1 grid
hold on;
stem(1:ii,sigmoid_function_x,'r') % probability - y axis;k - x axis; 
plot(1:ii,threshold,'--','Linewidth',2) 
hold off;
xlim([1 45]);
title('Sigmoid Function, Acceptance Pr > 0.46')
ylabel('Sigmoid Function')
xlabel('Distance')
% ylim([0.45 0.55])
grid on
%% Delete all previous output values and save all output as 0. Use debugging in line 815
% delete('out1.mat')
% delete('outout2.mat')
% delete('out3.mat')
% delete('out4.mat')
% delete('out5.mat')
% delete('out6.mat')
% delete('out7.mat')
% delete('out8.mat')
% delete('out9.mat')
% delete('outout10.mat')
% delete('out11.mat')
% delete('out12.mat')
% delete('out13.mat')
% delete('out14.mat')
% delete('out15.mat')
% delete('out16.mat')
% delete('out17.mat')
% delete('out18.mat')
% delete('out19.mat')
% delete('out20.mat')
% delete('dist_vec1.mat')
% d1 = 0; save('out1.mat','d1');
% d2 = 0; save('outout2.mat','d2');
% d3 = 0; save('out3.mat','d3');
% d4 = 0; save('out4.mat','d4');
% d5 = 0; save('out5.mat','d5');
% d6 = 0; save('out6.mat','d6');
% d7 = 0; save('out7.mat','d7');
% d8 = 0; save('out8.mat','d8');
% d9 = 0; save('out9.mat','d9');
% d10 = 0; save('outout10.mat','d10');
% d11 = 0; save('out11.mat','d11');
% d12 = 0; save('out12.mat','d12');
% d13 = 0; save('out13.mat','d13');
% d14 = 0; save('out14.mat','d14');
% d15 = 0; save('out15.mat','d15');
% d16 = 0; save('out16.mat','d16');
% d17 = 0; save('out17.mat','d17');
% d18 = 0; save('out18.mat','d18');
% d19 = 0; save('out19.mat','d19');
% d20 = 0; save('out20.mat','d20');

%%
    function PacmanCloseFcn
        stop(myTimer)
        delete(myTimer)
        delete(pacman_Fig)
        delete(pacmanGhostCreator_Fig)
    end
end