require 'sqlite3'

class Memos
    def initialize()
        begin
            @db = SQLite3::Database.new "memos.db"
            @db.results_as_hash = true

            # Create the table
            @db.execute "CREATE TABLE IF NOT EXISTS Memos(
                Id INTEGER PRIMARY KEY,
                sender TEXT,
                recvr TEXT,
                time TEXT,
                channel TEXT,
                memo TEXT)"
        rescue SQLite3::Exception => e
            puts "Exeception occured"
            puts e
        end
    end

    def add_memo(from, to, memo, time, channel)
        stmt = @db.prepare "INSERT INTO Memos(sender, recvr, time, channel, memo) VALUES(?, ?, ?, ?, ?)"

        stmt.bind_param 1, from
        stmt.bind_param 2, to
        stmt.bind_param 3, time.asctime
        stmt.bind_param 4, channel
        stmt.bind_param 5, memo

        stmt.execute
    end

    def get_memo(to)
        stmt = @db.prepare "SELECT sender, memo, time, channel FROM Memos WHERE recvr=?"

        stmt.bind_param 1, to

        result = []

        stmt.execute.each{ |row| result.push "[#{row['time']}] <#{row['channel']}/#{row['sender']}> #{row['memo']}"}
        remove_memos(to)
        result
    end

    def remove_memos(to)
        @db.execute "DELETE FROM Memos WHERE recvr='#{to}'"
    end
end

