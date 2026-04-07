using MySql.Data.MySqlClient;
using System.Data;

namespace GymManagementApp
{
    public static class DatabaseHelper
    {
        // ── Change Password= if your root account has a password set ──
        private const string ConnectionString =
            "Server=localhost;Database=GymDB;Uid=root;Password=;";

        // ── Core helpers ──────────────────────────────────────────────

        private static MySqlConnection GetConnection() =>
            new MySqlConnection(ConnectionString);

        /// <summary>Runs a SELECT and returns the result as a DataTable.</summary>
        public static DataTable ExecuteQuery(string sql, params MySqlParameter[] parameters)
        {
            using var conn = GetConnection();
            conn.Open();
            using var cmd = new MySqlCommand(sql, conn);
            cmd.Parameters.AddRange(parameters);
            using var adapter = new MySqlDataAdapter(cmd);
            var table = new DataTable();
            adapter.Fill(table);
            return table;
        }

        /// <summary>Runs INSERT / UPDATE / DELETE. Returns rows affected.</summary>
        public static int ExecuteNonQuery(string sql, params MySqlParameter[] parameters)
        {
            using var conn = GetConnection();
            conn.Open();
            using var cmd = new MySqlCommand(sql, conn);
            cmd.Parameters.AddRange(parameters);
            return cmd.ExecuteNonQuery();
        }

        // ── Member queries ────────────────────────────────────────────

        /// <summary>Returns every member row.</summary>
        public static DataTable GetAllMembers()
        {
            const string sql =
                "SELECT MemberID, FirstName, LastName, Phone, MemberType, " +
                "       JoinDate, ExpiryDate " +
                "FROM Members ORDER BY MemberID;";
            return ExecuteQuery(sql);
        }

        /// <summary>
        /// Searches members by any combination of ID, first name, last name.
        /// Empty / whitespace parameters are ignored.
        /// </summary>
        public static DataTable SearchMembers(string id, string firstName, string lastName)
        {
            var conditions = new List<string>();
            var parameters = new List<MySqlParameter>();

            if (!string.IsNullOrWhiteSpace(id))
            {
                conditions.Add("MemberID = @id");
                parameters.Add(new MySqlParameter("@id", id.Trim()));
            }
            if (!string.IsNullOrWhiteSpace(firstName))
            {
                conditions.Add("FirstName LIKE @fn");
                parameters.Add(new MySqlParameter("@fn", $"%{firstName.Trim()}%"));
            }
            if (!string.IsNullOrWhiteSpace(lastName))
            {
                conditions.Add("LastName LIKE @ln");
                parameters.Add(new MySqlParameter("@ln", $"%{lastName.Trim()}%"));
            }

            string where = conditions.Count > 0
                ? "WHERE " + string.Join(" AND ", conditions)
                : string.Empty;

            string sql =
                $"SELECT MemberID, FirstName, LastName, Phone, MemberType, " +
                $"       JoinDate, ExpiryDate " +
                $"FROM Members {where} ORDER BY MemberID;";

            return ExecuteQuery(sql, parameters.ToArray());
        }

        /// <summary>
        /// Inserts a new member. JoinDate = today; ExpiryDate = +1 month (Monthly) or +12 months (Annual).
        /// Returns true on success.
        /// </summary>
        public static bool AddMember(
            string firstName, string lastName, string phone, string memberType)
        {
            string interval = memberType == "Annual" ? "INTERVAL 12 MONTH" : "INTERVAL 1 MONTH";
            string sql =
                "INSERT INTO Members (FirstName, LastName, Phone, MemberType, JoinDate, ExpiryDate) " +
                $"VALUES (@fn, @ln, @phone, @type, CURRENT_DATE, DATE_ADD(CURRENT_DATE, {interval}));";

            return ExecuteNonQuery(sql,
                new MySqlParameter("@fn",    firstName),
                new MySqlParameter("@ln",    lastName),
                new MySqlParameter("@phone", phone),
                new MySqlParameter("@type",  memberType)) > 0;
        }

        /// <summary>
        /// Updates FirstName, LastName, Phone, and MemberType for the given MemberID.
        /// Returns true on success.
        /// </summary>
        public static bool UpdateMember(
            int id, string firstName, string lastName, string phone, string memberType)
        {
            const string sql =
                "UPDATE Members " +
                "SET FirstName = @fn, LastName = @ln, Phone = @phone, MemberType = @type " +
                "WHERE MemberID = @id;";

            return ExecuteNonQuery(sql,
                new MySqlParameter("@fn",    firstName),
                new MySqlParameter("@ln",    lastName),
                new MySqlParameter("@phone", phone),
                new MySqlParameter("@type",  memberType),
                new MySqlParameter("@id",    id)) > 0;
        }

        /// <summary>Deletes the member with the given MemberID. Returns true on success.</summary>
        public static bool DeleteMember(int id)
        {
            const string sql = "DELETE FROM Members WHERE MemberID = @id;";
            return ExecuteNonQuery(sql, new MySqlParameter("@id", id)) > 0;
        }
    }
}
