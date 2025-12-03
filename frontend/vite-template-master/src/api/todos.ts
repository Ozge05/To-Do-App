export type Todo = {
  id: number;
  title: string;
  description: string;
  done: boolean;
};

export type CreateTodoDto = {
  title: string;
  description?: string;
};

export type UpdateTodoDto = {
  title?: string;
  description?: string;
  done?: boolean;
};

const headers = {
  'Content-Type': 'application/json',
};

export async function listTodos(): Promise<Todo[]> {
  const res = await fetch('/api/todos');
  if (!res.ok) throw new Error('Todo listesi alınamadı');
  return res.json();
}

export async function createTodo(data: CreateTodoDto): Promise<Todo> {
  const res = await fetch('/api/todos', {
    method: 'POST',
    headers,
    body: JSON.stringify({ title: data.title, description: data.description ?? '', done: false }),
  });
  if (!res.ok) throw new Error('Todo oluşturulamadı');
  return res.json();
}

export async function updateTodo(id: number, data: UpdateTodoDto): Promise<Todo> {
  const res = await fetch(`/api/todos/${id}`, {
    method: 'PUT',
    headers,
    body: JSON.stringify(data),
  });
  if (!res.ok) throw new Error('Todo güncellenemedi');
  return res.json();
}

export async function deleteTodo(id: number): Promise<void> {
  const res = await fetch(`/api/todos/${id}`, { method: 'DELETE' });
  if (!res.ok) throw new Error('Todo silinemedi');
}
