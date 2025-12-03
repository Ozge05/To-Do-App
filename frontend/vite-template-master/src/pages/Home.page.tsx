import { useEffect, useMemo, useState } from 'react';
import {
  ActionIcon,
  Box,
  Button,
  Card,
  Center,
  Checkbox,
  Group,
  Stack,
  Text,
  TextInput,
  Textarea,
  Title,
} from '@mantine/core';
import { createTodo, deleteTodo, listTodos, updateTodo, type Todo } from '../api/todos';

export function HomePage() {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [loading, setLoading] = useState(false);
  const [todos, setTodos] = useState<Todo[]>([]);
  const [listLoading, setListLoading] = useState(false);

  const canSubmit = useMemo(() => title.trim().length > 0, [title]);

  async function load() {
    try {
      setListLoading(true);
      const data = await listTodos();
      setTodos(data);
    } catch (e) {
      // Opsiyonel: toast/notification eklenebilir
      // eslint-disable-next-line no-console
      console.error(e);
    } finally {
      setListLoading(false);
    }
  }

  useEffect(() => {
    load();
  }, []);

  async function handleAdd() {
    if (!canSubmit) return;
    try {
      setLoading(true);
      const created = await createTodo({ title: title.trim(), description: description.trim() });
      setTodos((prev) => [created, ...prev]);
      setTitle('');
      setDescription('');
    } catch (e) {
      // eslint-disable-next-line no-console
      console.error(e);
    } finally {
      setLoading(false);
    }
  }

  async function toggleDone(t: Todo) {
    try {
      const updated = await updateTodo(t.id, {
        title: t.title,
        description: t.description,
        done: !t.done,
      });
      setTodos((prev) => prev.map((x) => (x.id === t.id ? updated : x)));
    } catch (e) {
      // eslint-disable-next-line no-console
      console.error(e);
    }
  }

  async function remove(id: number) {
    try {
      await deleteTodo(id);
      setTodos((prev) => prev.filter((x) => x.id !== id));
    } catch (e) {
      // eslint-disable-next-line no-console
      console.error(e);
    }
  }

  return (
    <Center mih="100dvh" p="md">
      <Stack gap="xl" w={{ base: '100%', sm: 600 }}>
        <Card withBorder shadow="sm" radius="md">
          <Stack>
            <Title order={3} ta="center">
              To‑Do Uygulaması
            </Title>
            <Text c="dimmed" ta="center">
              Notunu eklemek için aşağıdaki alanları doldur ve Ekle’ye bas.
            </Text>
            <TextInput
              label="Başlık"
              placeholder="Örn: Alışveriş listesi"
              value={title}
              onChange={(e) => setTitle(e.currentTarget.value)}
              required
            />
            <Textarea
              label="Açıklama"
              placeholder="Detaylar (opsiyonel)"
              value={description}
              onChange={(e) => setDescription(e.currentTarget.value)}
              autosize
              minRows={2}
            />
            <Group justify="flex-end">
              <Button loading={loading} disabled={!canSubmit} onClick={handleAdd}>
                Ekle
              </Button>
            </Group>
          </Stack>
        </Card>

        <Box>
          <Group justify="space-between" mb="sm">
            <Title order={4}>Notlar</Title>
            <Button variant="light" onClick={load} loading={listLoading}>
              Yenile
            </Button>
          </Group>

          <Stack>
            {todos.length === 0 && (
              <Text c="dimmed">Henüz bir not yok. Yukarıdan bir not ekleyebilirsiniz.</Text>
            )}

            {todos.map((t) => (
              <Card key={t.id} withBorder p="md" radius="md">
                <Group align="flex-start" wrap="nowrap">
                  <Checkbox checked={t.done} onChange={() => toggleDone(t)} mt={4} />
                  <Box style={{ flex: 1 }}>
                    <Text fw={600} td={t.done ? 'line-through' : undefined}>
                      {t.title}
                    </Text>
                    {t.description && (
                      <Text c="dimmed" size="sm" td={t.done ? 'line-through' : undefined}>
                        {t.description}
                      </Text>
                    )}
                  </Box>
                  <ActionIcon variant="subtle" color="red" onClick={() => remove(t.id)} aria-label="Sil">
                    🗑️
                  </ActionIcon>
                </Group>
              </Card>
            ))}
          </Stack>
        </Box>
      </Stack>
    </Center>
  );
}
