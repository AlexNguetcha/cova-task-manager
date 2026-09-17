import com.covataskmanager.entity.Task;
import com.covataskmanager.entity.TaskPriority;
import com.covataskmanager.entity.TaskStatus;
import com.covataskmanager.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface TaskRepository extends JpaRepository<Task, Long> {

    Page<Task> findByUserOrderByCreatedAtDesc(User user, Pageable pageable);

    Page<Task> findByUserAndStatusOrderByCreatedAtDesc(User user, TaskStatus status, Pageable pageable);

    Page<Task> findByUserAndPriorityOrderByCreatedAtDesc(User user, TaskPriority priority, Pageable pageable);

    Page<Task> findByUserAndStatusAndPriorityOrderByCreatedAtDesc(User user, TaskStatus status, TaskPriority priority, Pageable pageable);

    @Query("SELECT t FROM Task t WHERE t.user = :user AND LOWER(t.title) LIKE LOWER(CONCAT('%', :search, '%')) ORDER BY t.createdAt DESC")
    Page<Task> searchByUserAndTitle(@Param("user") User user, @Param("search") String search, Pageable pageable);

    @Query("SELECT t FROM Task t WHERE t.user = :user AND t.status = :status AND LOWER(t.title) LIKE LOWER(CONCAT('%', :search, '%')) ORDER BY t.createdAt DESC")
    Page<Task> searchByUserAndStatusAndTitle(@Param("user") User user, @Param("status") TaskStatus status, @Param("search") String search, Pageable pageable);

    @Query("SELECT t FROM Task t WHERE t.user = :user AND t.status = :status AND t.priority = :priority AND LOWER(t.title) LIKE LOWER(CONCAT('%', :search, '%')) ORDER BY t.createdAt DESC")
    Page<Task> findByUserAndStatusAndPriorityAndTitleContaining(@Param("user") User user, @Param("status") TaskStatus status, @Param("priority") TaskPriority priority, @Param("search") String search, Pageable pageable);

    Page<Task> findByUserAndStatusAndPriority(User user, TaskStatus status, TaskPriority priority, Pageable pageable);
}